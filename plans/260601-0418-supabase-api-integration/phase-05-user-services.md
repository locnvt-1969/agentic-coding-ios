# Phase 05 — User-context services (needs session)

**Priority:** High · **Status:** DONE (2026-06-01 Batch 2–6: all user-context + comment submission complete) · **Depends:** P02, P03

**Implementation summary (2026-06-01 Batches 2–6) — Self-Profile + Kudos READ/WRITE/REACT/COMMENT + Secret Box all DONE:**
- UserService.fetchCurrentUser/fetchUser/fetchProfileStats/searchSunners + listDepartments (all wired, live Batch 6)
- KudoService: listReceivedKudos ← list_kudos RPC; sendKudo ← insert + hashtags; listHashtags; **viewKudo ← view_kudo RPC + comments**; **react/unreact ← insert/delete reactions**; **addComment(kudoId, text) ← insert comment** (Batch 6)
- **spotlightTotalKudos ← real count**; **fetchPersonalStats ← v_profile_stats (received/sent/hearts)**; **listGiftRecipients ← v_recent_gift_recipients** (all Batch 6)
- Board hashtag/department filters wired (Batch 6: list_kudos RPC extended to 6 args)
- **SecretBoxService.currentBox + openBox** ← GET/RPC (optimistic, auto-grant on 5-heart trigger, icon collection)
- Comment submission: KudoService.addComment + ViewKudoViewModel + Container wiring complete; keeps text on failure (Batch 6)
- Build: SUCCEEDED, Review: 0-critical (all fixes applied), End-to-end: verified (all Kudo features real)

## Status breakdown

**DONE (Batch 2–6):** 
- UserService: fetchCurrentUser + fetchProfileStats + fetchUser + searchSunners + listDepartments (wired, live)
- KudoService: listReceivedKudos + sendKudo + listHashtags + viewKudo + react/unreact + **addComment** (all wired, live, optimistic UI, Batch 6)
- KudoService: spotlightTotalKudos + fetchPersonalStats + listGiftRecipients + board filters (Batch 6)
- **SecretBoxService.currentBox + openBox** (wired, live, Batch 5 security applied)

**PENDING (Batch 7+):** NotificationService (stub: listNotifications/markRead/unreadCount); Awards screen (mock data).

## Goal
Wire services that depend on the logged-in user (`auth.uid()` via RLS).

## Steps
1. **`UserService`**:
   - `fetchCurrentUser()` → RPC `get_profile(auth.uid())` → `User` (+ level + collected icons).
   - `fetchUser(id)` → RPC `get_profile(id)`.
   - `fetchProfileStats(userId)` → `v_profile_stats?profile_id=eq.<id>`.
   - `searchSunners(query)` → `profiles?or=(full_name.ilike.*q*,...)&select=*,departments(*)`.
2. **`KudoService`**:
   - `sendKudo(payload)` → insert `kudos` (sender_id = uid, recipient_id, title, message, is_anonymous) → then insert `kudo_hashtags`.
   - `viewKudo(id)` → `kudos_public?id=eq.<id>` + `kudo_comments?kudo_id=eq.<id>&select=*,author:profiles(*)`.
   - **`react(kudoId)` / `unreact(kudoId)`** (new) → insert / delete `kudo_reactions` (profile_id = uid). Triggers auto-grant secret boxes.
3. **`SecretBoxService`**:
   - `currentBox()` → `secret_boxes?profile_id=eq.uid&state=neq.opened&order=created_at&limit=1`.
   - `openBox()` → RPC `open_secret_box(box_id)` → `Gift`/value icon.
4. **`NotificationService`**: `listNotifications()` → `notifications?recipient_id=eq.uid&order=created_at.desc`; `markRead(id)` → PATCH; `unreadCount()` → count where `is_read=false`.

## Files
- modify: `Services/UserService.swift`, `Services/KudoService.swift`, `Services/SecretBoxService.swift`, `Services/NotificationService.swift`

## Success criteria
- Logged in: Profile self/other (info, stats, icons, hero tier), send kudo, heart/un-heart, open secret box, notifications all hit real DB; RLS allows own writes, blocks others.
- Sending a kudo + accumulating 5 ❤️ creates a secret box (trigger); opening grants an icon. ✅ VERIFIED (Batch 5: 5 boxes → open → icon + count decrement).
