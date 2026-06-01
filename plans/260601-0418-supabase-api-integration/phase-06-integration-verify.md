# Phase 06 — UI/ViewModel wiring + integration & verify

**Priority:** High · **Status:** KUDO BOARD COMPLETE (Batch 6) · **Depends:** P04, P05

**Status (2026-06-01 Batch 2–6):**
- ✅ Reactions UI: tappable heart (filled/outline reflects has_reacted); optimistic toggle w/ rollback; per-id in-flight guard (Batch 4)
- ✅ Send Kudo flow: `SendKudoViewModel.submit` → real `sendKudo`; recipient picker (searchSunners); hashtags live (Batch 4)
- ✅ View Kudo detail + **comments READ**: `viewKudo` RPC fetches kudo + all comments with authors (Batch 4)
- ✅ **Comment SUBMISSION**: `KudoService.addComment(kudoId, text)` + `ViewKudoViewModel.addComment` + Container wiring; keeps text on failure (Batch 6)
- ✅ Profile: real `get_profile`; other-profile via `fetchUser`; received kudos + real stats (Batch 2+3)
- ✅ **Secret Box wired** (Batch 5): `SecretBoxViewModel` → `currentBox/openBox`; availableCount guard; icon reveal
- ✅ **Board highlights wired** (Batch 6): spotlight count + personal stats (received/sent/hearts) + gift recipients + hashtag/dept filters
- ✅ `FeatureFlags.useMockKudoData → false`; `KudoService+Mock.swift` deleted; all Kudo features real
- ✅ E2E verified: login → profile/board → send kudo → reactions → detail + comments → secret box (all live)
- ⏳ **Notifications** (`NotificationViewModel` → list/mark-read) — PENDING (Batch 7+)

## Remaining Steps (Batch 7+)

1. **Notifications**: wire `NotificationService.listNotifications()`/`markRead()`/`unreadCount()` → `NotificationViewModel`.
2. **Awards screen**: migrate from mock to Supabase (`AwardService`/`AwardsService`).

## Files modified (Batches 2–6)
**Batch 6 (latest):**
- `supabase/migrations/20260601001300_kudo_board_extras.sql` — list_kudos extended + v_recent_gift_recipients
- `Services/KudoService.swift` — addComment, listKudos (filters), spotlightTotalKudos (real count), fetchPersonalStats, listGiftRecipients
- `Services/SupabaseRESTClient.swift` — count() method (Content-Range header)
- `Services/UserService.swift` — listDepartments (real GET), removed mockDepartments
- `ViewModels/ViewKudoViewModel.swift` — addComment async flow
- `Views/Containers/ViewKudoContainer.swift` — onComment handler
- `Views/KudoDetail/ViewKudoView.swift` — async comment form
- DELETED `Services/KudoService+Mock.swift`

**Batches 2–5:** Reactions, send kudo, profile, secret box, detail comments (see phase-05 + plan.md Batch summaries)

## Success criteria (Batch 6 — COMPLETE)
- ✅ E2E: login → profile/board → send kudo → heart/unreact → detail + comments (read+write) → secret box → filters/stats/gifts. Build SUCCEEDED; Review 0-critical.
- ✅ Spotlight count (real), personal stats (received/sent/hearts), gift recipients, hashtag/dept filters all verified.
- ✅ Mock removed: `FeatureFlags.useMockKudoData → false`, `KudoService+Mock.swift` deleted.
- ⏳ Remaining: NotificationService, Awards screen (Batch 7+).
