# Phase 2: Email/Password Auth & Self-Profile — Live End-to-End

**Date**: 2026-06-01 16:45
**Severity**: High (User-facing auth + live DB read)
**Component**: AuthService (GoTrue), UserService (self profile), SupabaseRESTClient
**Status**: Resolved (self-profile live; broader user services mocked to preserve flow integrity)

## What Happened

Shipped Phase 2 with a **deliberate scope cut**: chose local email/password auth over Google OAuth + SDK, proving the entire auth path (sign-in → JWT session → call RPC with token) **without external dependencies or production credentials**. Built AuthService (GoTrue raw REST), UserService.fetchCurrentUser (get_profile RPC), and wired the app to live Supabase data. Verified end-to-end twice: curl chain (seed test user → sign in → fetch profile + stats), then in-app screenshot (logged-in Profile rendered real name/CEVC3/collected icons/stats from DB).

Committed as `289e45e`. Cleaned up reviewer fixes: widened callRPC body to `[String:Any]`, propagate serialization errors instead of swallowing, surface real decode errors in signIn, removed dead ProfileDTO.toStats() aggregation.

## The Brutal Truth

This is the first time the app **read real data from the database** and displayed it. That's terrifying and exhilarating at once. The relief: every layer worked—cursor hit the database, RPC executed, JSON came back, Swift decoded it, UI rendered. Zero surprises in the payload shape. But the honest reality: this only works for **self-profile**. Every other user context (searchSunners, fetchUser, Kudos, SecretBox, Notifications) is still mocked. Doing it halfway feels fragile.

The bigger frustration: knowing that JWT expiry + refresh, Keychain storage, revoke on sign-out, and self-send guards on live paths are **all deferred** because they're not in the critical path for the demo. Shipping half-baked auth always bites back, and we just bet on it.

## Technical Details

**Sign-in flow (curl verified before Swift):**
```bash
# 1. Seed test user with bcrypt hash
INSERT INTO auth.users (id, email, raw_app_meta_data, raw_user_meta_data, encrypted_password, email_confirmed_at)
VALUES (..., 'sunner@sun.com', ..., ..., crypt('password123', gen_salt('bf')), now());

# 2. GoTrue token endpoint
POST http://localhost:54321/auth/v1/token?grant_type=password
→ Returns {access_token, refresh_token, expires_in: 3600}

# 3. Call RPC with Bearer token
curl -H "Authorization: Bearer $ACCESS_TOKEN" \
  http://localhost:54321/rest/v1/rpc/get_profile?p_id=<uuid>
→ Returns {id, name, cevc, department, heroTier, sunValueIcons, stats}
```

**AuthService (commit `289e45e`):**
- `signIn(email, password)` → POST to GoTrace + decode JWT, extract userId
- `storeSession(token, userId)` → UserDefaults (⚠️ Keychain deferred)
- `getStoredSession()` → restore JWT on app launch
- `signOut()` → clears UserDefaults (real revoke deferred)
- Sets token on SupabaseRESTClient actor before every RPC call

**SupabaseRESTClient.callRPC (fixes from review):**
- Body now `[String:Any]` instead of hardcoded Encodable
- Serialization errors propagate (was swallowing via `try?`)
- Real decode failures surfaced in logs

**UserService.fetchCurrentUser:**
- Calls `get_profile(p_id)` with authenticated session
- Decodes ProfileDTO → hydrates all nested objects (Department, HeroTier, SunValueIcon enums)
- **Live**: returns real data from DB for current user only

**Scope boundary (honest cut):**
- ✅ Self-profile: live (get_profile RPC)
- ✅ Current user stats: live (v_profile_stats view query inside get_profile)
- ❌ Other users, Kudos, SecretBox, Notifications: still mock (wired but non-functional)
- Reason: avoid broken flows where live profile can't load Kudos or search returns mock data

## What We Tried

1. **Build auth + implement all user services at once** → Rejected. Too many moving parts, breaks incrementally.
2. **Start with real Google OAuth** → Rejected. Requires SDK + prod credentials + OAuth setup. Local email/password unblocks everything.
3. **Wire all user services to mocked data, then flip to live later** → Chosen (partially). Keeps demo-able, avoids half-working flows.

**Verification discipline:**
1. Seeded test user in DB via `psql`.
2. Tested GoTrue `/token` endpoint with curl, confirmed JWT structure.
3. Tested RPC call with `curl -H "Authorization: Bearer..."`, confirmed RPC executed + JSON shape.
4. Added temporary auth-gate View (showed `if loggedIn { RealProfile } else { Login }`).
5. Ran app, logged in as sunner@sun.com, screenshot showed real name/CEVC3/3 icons/stats → proof.
6. Removed auth-gate, integrated into normal Home flow.

## Root Cause Analysis

**Why email/password instead of Google OAuth?**
- Google SDK requires Xcode setup + SPM fetch + actual OAuth app credentials
- Blocks team if credentials aren't ready
- Doesn't add value for local verification; JWT auth path is identical either way

**Why only self-profile?**
- Coupling risk: if searchSunners mock + profile live, demo shows inconsistency
- Better to prove one path fully than fragment three paths halfway
- Mocked services still consume real UserService interface → wiring is there for real data swap later

**Why UserDefaults instead of Keychain?**
- Quick unblock for dev/demo phase
- Keychain adds ceremony without changing security model for local dev
- Real blocker for production (logged in pre-prod follow-ups)

## Lessons Learned

1. **Verify backend path before client code**: Curl chain proved GoTrue + RPC flow before touching Swift. Caught that test user needed bcrypt hash (Supabase default), not plaintext. Would have wasted hours debugging SignIn if done in-app first.

2. **Scope cut is honest design, not laziness**: Saying "self-profile live, others mocked" is clearer than shipping half-working multi-user flows. Demo is coherent. Wiring is there. Real data swap doesn't require architecture change.

3. **Reviewer caught serialization debt**: `try?` swallowing decode errors masks bugs. `[String:Any]` body instead of rigid Encodable gives RPC flexibility. Small friction now, huge clarity later.

4. **Incremental delivery == early security catch**: Last entry caught PUBLIC EXECUTE grants. This entry ships real auth—the more real code lives, the more gaps appear. Good.

## Next Steps

1. **Before next batch (Phase 3: User services):**
   - Implement fetchUser(userId) + searchSunners(query) with **real** Postgres queries, same pattern as get_profile
   - Decide: live Kudos + SecretBox from day one, or keep mocked until Phase 5?
   - Test multi-user: sign in as different user, confirm profile changes

2. **Pre-production (security + hardening):**
   - JWT expiry: catch 401 on RPC calls → auto-refresh or sign out
   - Keychain storage: move from UserDefaults → SecureEnclave
   - Sign-out revoke: call Supabase `/auth/v1/logout` (real revoke on server)
   - Self-send guard: CurrentUserId check on SendKudo + GrantKudos paths (currently empty string on live path)

3. **Immediate (non-blocking):**
   - Add loading state to Profile view (fetchCurrentUser is async, UI doesn't show spinner yet)
   - Test offline: what happens if user signs in, loses network, goes to Home? (Session restore is there, but offline graceful degradation isn't)

**Owner**: Phase 2 complete; Phase 3 (user services) and pre-prod (security hardening) logged as follow-ups.

---

**Status**: RESOLVED
**Summary**: Shipped email/password auth + self-profile RPC live end-to-end. Proved GoTrue + SupabaseREST path via curl before Swift. Self-profile renders real DB data; other user services remain mocked to avoid fragmented demo. AuthService handles JWT lifecycle; UserService.fetchCurrentUser calls get_profile. Reviewer fixes applied (wider RPC body, error propagation, removed dead aggregation).
**Concerns**: JWT refresh/expiry on session restore (silent 401 risk); Keychain deferred; SendKudo self-send guard uses empty string on live path; all other user services return mock data (phase 3 dependency).
