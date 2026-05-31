# Phase 05 — User-context services (needs session)

**Priority:** High · **Status:** pending · **Depends:** P02, P03

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
