# Phase 05 — User-context services (needs session)

**Priority:** High · **Status:** DONE (2026-06-01 Batch 2+3+4+5) · **Depends:** P02, P03

**Implementation summary (2026-06-01 Batches 2–5) — Self-Profile + Kudos READ/WRITE/REACT + Secret Box all DONE:**
- UserService.fetchCurrentUser() ← get_profile(uid) RPC; fetchUser(id) ← get_profile(id); fetchProfileStats(userId) ← v_profile_stats; searchSunners(query) ← ilike + embed depts; wired + live verified
- KudoService.listReceivedKudos(userId) ← list_kudos(p_recipient=userId) RPC; wired to ProfileViewModel
- **KudoService.viewKudo(kudoId)** ← **view_kudo RPC returning kudo + comments**; **react(kudoId)/unreact(kudoId)** ← insert/delete kudo_reactions; optimistic UI in ViewModels
- **KudosBoardViewModel.toggleReaction** + **ViewKudoViewModel.toggleReaction** — per-id in-flight guard, optimistic state, rollback on error
- **SecretBoxService.currentBox()** ← GET secret_boxes (state=closed, count unopened); **openBox()** ← RPC open_secret_box (oldest closed → random un-owned icon, all-collected gate). SecretBoxViewModel with availableCount guard; SecretBoxContainer wired (Batch 5).
- UI: tappable ❤️ (filled/outline = has_reacted) on board cards + detail action bar; Secret Box screen shows count, opens to reward/icon collection
- ProfileSelfContainer: displays real name/dept/icons/stats; other-profile via fetchUser; Kudos section shows received kudos with real reaction counts
- Build: SUCCEEDED, Review: 0-critical (all fixes applied), End-to-end: verified (login → profile → kudos with reactions → detail + comments → open secret boxes)

## Status breakdown

**DONE (Batch 2–5):** 
- UserService.fetchCurrentUser + fetchProfileStats + fetchUser + searchSunners (all wired, live)
- KudoService.listReceivedKudos + sendKudo + listHashtags + **viewKudo (with comments)** + **react/unreact** (all wired, live, optimistic UI confirmed)
- **SecretBoxService.currentBox + openBox** (wired, live, auto-grant trigger + icon collection verified, Batch 5 security hardening applied)
- Kudo.hasReacted property + reaction count UI

**PENDING (Batch 6+):** NotificationService.listNotifications/markRead/unreadCount; board hashtag/dept filter UI wiring (RPC present but UI skipped); comment SUBMISSION (write); spotlight/personalStats/giftRecipients.

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
