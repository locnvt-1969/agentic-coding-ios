# Phase 06 — UI/ViewModel wiring + integration & verify

**Priority:** High · **Status:** PARTIAL (2026-06-01 Batch 4) · **Depends:** P04, P05

**Status (2026-06-01 Batch 4):**
- ✅ Reactions UI: tappable heart on KudoCard (board + All Kudos) + ViewKudoDetail action bar; `hasReacted` reflects (filled/outline); optimistic toggle w/ rollback on error
- ✅ Send Kudo flow: `SendKudoViewModel.submit` → `KudoService.sendKudo`; recipient picker uses `searchSunners`; hashtags from `listHashtags`; success → pop + toast
- ✅ View Kudo detail: `viewKudo` RPC fetches kudo + comments; detail screen displays comments with authors
- ✅ Profile: `ProfileViewModel` consumes real `get_profile`; other-profile via `fetchUser` (no mock fallback)
- ✅ Remove mock fallbacks: `FeatureFlags.useMockKudoData → false`; dead mock removed; `ContentService.figmaSample` kept for preview only
- ✅ Dev seed: `supabase/seeds/dev/10_dev_kudos.sql` seeded kudo_comment for detail screen real content
- ✅ Verify: E2E tested (login → Profile → Kudos board → send kudo → heart toggle → detail + comments); reactions counted; curl + screenshot verified
- ⏳ **Secret Box** (`SecretBoxViewModel` → `currentBox`/`openBox`; icon reveal) — PENDING
- ⏳ **Notifications** (`NotificationViewModel` → list/mark-read/unread-count) — PENDING
- ⏳ **Board hashtag/dept filter UI** (RPC list_kudos present, UI wiring skipped) — PENDING
- ⏳ **Comment SUBMISSION** (write) — PENDING (only read implemented this batch)

## Remaining Steps (next batch)

1. **Secret Box**: wire `SecretBoxService.currentBox()`/`openBox()` → `SecretBoxViewModel` → display + reveal icon.
2. **Notifications**: wire `NotificationService.listNotifications()`/`markRead()`/`unreadCount()` → `NotificationViewModel`.
3. **Board filters**: add hashtag/department dropdowns to `KudosBoardView` → pass to `list_kudos(p_hashtag?, p_department?)`.
4. **Comment write**: add comment form to `ViewKudoDetail` → call `KudoService.submitComment(kudoId, text)`.

## Files modified (Batch 4)
- `Services/KudoService.swift` — viewKudo + react/unreact methods
- `ViewModels/KudosBoardViewModel.swift` — toggleReaction (optimistic, per-id guard)
- `ViewModels/ViewKudoViewModel.swift` — toggleReaction (optimistic, per-id guard)
- `Views/Kudos/KudoCard.swift` — tappable heart tied to toggleReaction
- `Views/KudoDetail/ViewKudoDetail.swift` — tappable heart action bar; comments from real data
- `supabase/migrations/20260601001100_kudo_interactions.sql` — view_kudo RPC + kudo_json builder
- `supabase/seeds/dev/10_dev_kudos.sql` — comment seed data

## Success criteria (current + next)
- ✅ E2E tested: login → home → kudos board → send kudo → heart toggle (optimistic + DB) → view kudo detail + comments (live). Build green; reviewer 0-critical.
- ⏳ Next: same + open secret box + unread notification count → all real data E2E; no mock fallbacks except ContentService.figmaSample.
