# Phase 11: Kudos Board — Live RPC + Anonymity Defense-in-Depth

**Date**: 2026-06-01 10:30
**Severity**: High (Live feed + anonymity constraint)
**Component**: KudosService, KudoDTO, Postgres RPC (list_kudos), v_kudos_public VIEW
**Status**: Resolved (board live; write paths + detail view deferred)

## What Happened

Shipped the Kudos board (commit `8864e47`) wired to live Postgres: `list_kudos` RPC returns a composed JSON payload with sender/recipient profiles, hashtags, and reaction counts. Chosen RPC over PostgREST embedding because views (v_kudos_public) can't embed relations—the API shape needed anonymity baked in (sender null when anonymous) plus aggregated reaction_count, both harder to compose in Swift. Seeded a buddy user + 5 kudos (1 anonymous, 1 spam for testing) + reactions. Verified via curl and in-app screenshot of the board rendering real data.

## The Brutal Truth

**The regression was embarrassing:** Reviewer caught me swapping deterministic mock lists for a live global endpoint without checking every caller. I wired `ProfileViewModel.kudos` to `KudoService.listAllKudos` (the board feed), which meant the profile showed **everyone's kudos** instead of just received ones. Wrong count too—`kudos.count` on the live list hit 5 (all), not 1-2 per user. That's the kind of mistake that ships to QA and gets "why does my profile show my teammate's achievements?" 

The fix was obvious in hindsight: per-user `listReceivedKudos(userId)` filtering server-side (WHERE recipient_id = $1), and let the v_profile_stats view own the count. But I didn't think about it because I was focused on getting the board live. **Lesson: shared service methods are shared contracts.** When swapping from mock to live, trace every caller and re-check assumptions.

The deeper frustration: I knew anonymity was tricky. I built a CASE in the list_kudos RPC, refactored to read from v_kudos_public, added the same logic. That's DRY violation at the SQL layer—one rule, two places. Fixed it by moving anonymity into the view definition itself, so the RPC is just select/compose.

## Technical Details

**RPC: list_kudos (p_board_id UUID, p_limit INT)** → Postgres call signature
```sql
SELECT
  id,
  created_at,
  sender JSON,        -- {id, name, cevc, department} or null if anonymous
  recipient JSON,     -- always populated
  message,
  hashtags JSON,      -- array of {id, tag, color} objects
  reaction_count,
  is_spam
FROM v_kudos_public(p_board_id, least(p_limit, 100))  -- cap at 100 for DoS guard
```

**v_kudos_public VIEW (anonymity as single source of truth):**
```sql
CREATE VIEW v_kudos_public AS
SELECT
  k.id,
  CASE WHEN k.is_anonymous THEN NULL ELSE (sender profile JSON) END as sender,
  (recipient profile JSON) as recipient,
  -- ... hashtags, counts
FROM kudos k
LEFT JOIN profiles sender_profile ON k.sender_id = sender_profile.id
LEFT JOIN profiles recipient_profile ON k.recipient_id = recipient_profile.id
```
The view owns anonymity. RPC reads it. KudoDTO decodes it. Three layers, one rule.

**KudoService methods (commit `8864e47`):**
- `listAllKudos(boardId, limit)` → calls RPC, returns [Kudo] (board feed only)
- `listKudos(boardId)` → wrapper with default limit (UI convenience)
- `listReceivedKudos(userId)` → calls RPC with recipient filter, returns [Kudo] (profile stats)

**KudoDTO decoder:**
- Handles nullable `sender` (anonymous case)
- Decodes nested profiles, hashtags, reaction count
- Validates that `recipient` is always present (non-optional struct)

**Seeding (test data in schema):**
```sql
INSERT INTO kudos (id, sender_id, recipient_id, board_id, message, is_anonymous, is_spam, created_at)
VALUES (uuid(), user_buddy.id, user_sundari.id, board.id, 'Great work!', false, false, now()),
       (uuid(), NULL, user_sundari.id, board.id, 'Secret admirer', true, false, now()),
       (uuid(), user_buddy.id, user_harish.id, board.id, 'SPAM SPAM SPAM', false, true, now());
-- Plus 2 more with hashtags + reactions seeded separately
```

**Verification chain:**
1. Curl: `GET /rpc/list_kudos?p_board_id=<uuid>&p_limit=10` with Bearer token → JSON payload returned
2. KudoDTO.decode on curl JSON → parsed all 5 kudos, sender null on anonymous kudo
3. In-app: Kudos board screenshot showing real message, sender name (or "Anonymous"), reaction counts
4. Profile view now calls `listReceivedKudos(currentUserId)` → filters to 1-2 per user

## What We Tried

1. **PostgREST resource embedding** (Kudos?select=*,sender:profiles(*),recipient:profiles(*)) → Rejected. PostgREST can't embed from views; schema read-only doesn't support it.
2. **Client-side anonymity (filter in Swift)** → Rejected. Leaks sender_id in JSON payload; broken contract.
3. **RPC with CASE + inline profile serialization** → Chosen, then refactored. Worked, but anonymity logic duplicated in RPC + VIEW.
4. **Move anonymity to view, RPC reads view** → Chosen (final). Single source of truth.

## Root Cause Analysis

**Why the regression?**
- Habit: in mock mode, I wrote `KudoService.listAllKudos` returning a static array. Easy to use everywhere.
- Lazy review: didn't trace ProfileViewModel.kudos assignment when swapping to live.
- Assumption unchecked: thought "listAllKudos is generic, any caller can use it." Not true when the callers need different filters.

**Why RPC instead of PostgREST?**
- Anonymity rule + aggregation (reaction_count) require server-side composition
- PostgREST embedding doesn't support views in the "select" parameter
- RPC is the path-of-least-resistance for complex JSON shapes

**Why the view refactor?**
- First cut: CASE in RPC + CASE in (hypothetical) ReactKudo write RPC = maintenance burden
- Clean cut: anonymity rule lives in the view schema. RPC/write paths reference it.
- Upside: if anonymity rule changes (e.g., "show sender but blank name"), one place to update

**Why cap at 100?**
- Small guard against accidental large-limit requests (p_limit=999999)
- Pagination isn't implemented yet; cap prevents runaway query
- Real pagination comes with board filtering (phase 13)

## Lessons Learned

1. **Regression: shared service methods are shared contracts.** When a method returns live data, every caller has a stake. Trace usage before swapping mock → live. For this one: ProfileViewModel needed filtered list, not global. Solution was to add a second method (listReceivedKudos) instead of changing the contract of the first.

2. **Defense-in-depth for anonymity:** Putting the rule in three places (VIEW, RPC, client decoder) feels like overkill until it's not. If any layer bugs out, the next one still holds. Here: view owns the rule, RPC reads it cleanly, decoder validates. If someone eyeballs the raw RPC JSON and forgets to null-check sender, the view already protected the secret.

3. **DRY at the SQL layer matters.** First version had CASE in RPC. If a write RPC (sendKudo) also needed to anonymize, it would duplicate the logic. Moving it to the view forced me to think "what's the canonical rule?" and encode it once. Refactoring before the dupe was worth it.

4. **Seeding test data up front catches contract gaps.** The seeded anonymous kudo hit a NULL in the decoder (sender field) and I caught it before the app crashed. Real data surfaced a shape I hadn't tested.

## Next Steps

1. **Immediate (this batch):**
   - ✅ Regression fix: ProfileViewModel now calls `listReceivedKudos(userId)` with verified filter
   - ✅ View refactored; anonymity rule centralized

2. **Phase 12 (Kudo writes + reactions):**
   - Implement `sendKudo(senderId, recipientId, message, hashtags, isAnonymous)` RPC
   - Implement `reactKudo(kudoId, userId, reactionType)` RPC (returns updated reaction_count)
   - Implement `unreactKudo(kudoId, userId)` RPC
   - Self-send guard: `senderId != recipientId` enforced server-side
   - Test anonymous + non-anonymous send; verify anonymity rule holds on write

3. **Phase 13–15 (filtering, detail, profile integration):**
   - Kudo detail view (viewKudo by id, show sender profile if not anonymous)
   - Board filters: hashtag, department (requires server-side filter params on RPC)
   - Profile Kudos section: integrate live `listReceivedKudos` (already wired)

4. **Deferred (logged, not blocking):**
   - SecretBox (anonymous message inbox, phase 16)
   - Notifications on sendKudo/reaction (phase TBD)
   - Other-profile (search + fetchUser, phase 9; depends on live user services)
   - Kudo.title rendering in board cards (UI only, P6)
   - Hashtag autocomplete (server TBD)

5. **Pre-prod (security + hardening):**
   - Revoke PUBLIC EXECUTE on all migration-700 RPC functions (currently open)
   - Move dev creds behind `#if DEBUG` blocks in AuthService
   - Rate-limit sendKudo + react endpoints (DDoS guard)

**Owner**: Phase 11 complete (live board feed + anonymity); Phase 12 (writes) is next unblocked task.

---

**Status**: RESOLVED
**Summary**: Wired Kudos board to live RPC (list_kudos). Anonymity rule owned by v_kudos_public view; RPC and decoder read from it (defense-in-depth). Seeded 5 kudos (1 anonymous, 1 spam) + reactions. Verified curl → in-app. Regression caught by reviewer: ProfileViewModel was calling global listAllKudos instead of per-user listReceivedKudos. Fixed with dedicated method + profile stats source change.
**Concerns**: Write RPCs (sendKudo, react) deferred to phase 12; Notifications/SecretBox blocked on write RPC; all other user services still mocked; PUBLIC EXECUTE revoke + dev creds hardening pre-prod.
