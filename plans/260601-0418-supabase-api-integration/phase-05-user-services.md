# Phase 05 — User-context services (needs session)

**Priority:** High · **Status:** PARTIAL (2026-06-01 Batch 2+3) · **Depends:** P02, P03

**Implementation summary (2026-06-01 Batches 2–3) — Self-Profile + Kudos READ paths DONE:**
- UserService.fetchCurrentUser() ← get_profile(uid) RPC → User + icons + dept; wired
- UserService.fetchProfileStats(userId) ← v_profile_stats view; wired
- KudoService.listReceivedKudos(userId) ← list_kudos(p_recipient=userId) RPC; wired to ProfileViewModel
- ProfileSelfContainer: displays real name/dept/icons/stats from DB; Kudos section shows user's received kudos from DB
- Build: SUCCEEDED, Review: 7/10 0-critical (Batch 3), End-to-end: verified (login → Profile, Kudos board, All Kudos show live DB data)

## Status breakdown

**DONE (Batch 2–3):** UserService.fetchCurrentUser + fetchProfileStats; KudoService.listReceivedKudos (reads profile's received kudos from DB).

**PENDING (Batch 4+):** KudoService.sendKudo/viewKudo/react/unreact + listHashtags + spotlight/personalStats/giftRecipients; SecretBoxService.currentBox/openBox; NotificationService.listNotifications/markRead/unreadCount; UserService.fetchUser/searchSunners; board hashtag/dept filters.

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
- Sending a kudo + accumulating 5 ❤️ creates a secret box (trigger); opening grants an icon.
