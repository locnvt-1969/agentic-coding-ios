# Development Roadmap

Last updated: 2026-06-01

---

## Phase 1 — Project Setup
**Status: Complete**

- iOS project scaffolded (Xcode, SwiftUI, MVVM + Router structure)
- Supabase local instance configured
- Git repository initialized

---

## Phase 2 — Login Screen
**Status: Complete**

- `LoginView` + `LoginContainerView` with Google sign-in button
- `AuthService` (Google OAuth stubbed — Supabase Swift SDK not yet installed)
- `AppRouter` with `.login` / `.home` routes
- `AppLanguage` model, `LanguageDropdownView`

---

## Phase 3 — Home Screen
**Status: Complete**

- `HomeView` + sub-components: header, hero/countdown, awards section, kudos section, theme section, bottom nav bar, FAB
- `HomeViewModel` driving `AwardsLoadState`
- `AwardsService`: URLSession → Supabase REST `/rest/v1/awards`
- `CountdownTimer`: ticks toward 2025-12-26 00:00 Asia/Saigon
- `ToastCenter` + `ToastBannerView`: app-level ephemeral overlay
- `SupabaseConfig`, `FeatureFlags` (`isKudosAvailable`)
- Supabase migration + seed for `public.awards` (RLS, anon-read)
- AppRoute extended: `.awards / .kudos / .profile` (placeholder views)

---

## Phase 4 — Awards Screen
**Status: Not started**

---

## Phase 5 — Kudos Screen (READ + interact API wired)
**Status: In Progress (READ ✓, react/unreact ✓, viewKudo ✓; spotlight/stats/giftRecipients pending)**

- `KudosBoardView` + sub-sections: `SpotlightBoardSection` (388 Kudos stat, chart image, non-functional search), `KudosStatsBlock` (personal received/sent counts, heart + x2-fire badge, Secret Box opened/unopened), `GiftRecipientsList` (Top-10 gift recipients)
- `KudosStats`, `GiftRecipient` models added
- `KudoService` — `listAllKudos(page)` + `listKudos()` + `listReceivedKudos(userId)` wired to live `list_kudos` RPC (DB); RPC now returns `has_reacted` per user
- `KudoService.viewKudo(id:)` — live; calls `view_kudo` RPC; returns kudo + comments
- `KudoService.react` / `unreact` — live; POST / DELETE to `kudo_reactions`; optimistic toggle with in-flight guard and rollback
- `Kudo.hasReacted` — new model field; ❤️ button on board tappable; kudo detail shows comments (read-only)
- `ProfileViewModel` — kudos property reads RECEIVED kudos; received/sent counts from live `v_kudos_stats` view
- Build: SUCCEEDED · Review: DONE · End-to-end verified
- **Known follow-ups:** Spotlight search / Top-10 tap remain non-functional; board hashtag/dept filters not wired; Kudo.title rendering in KudoCard deferred; comment submission deferred

---

## Phase 6 — Profile Screen
**Status: Complete (live DB wired for self-profile)**

- `ProfileSelfView` + `ProfileOtherView` wired with service layer
- `SunValueIcon` collection rendering with dynamic labels + DB slug mapping
- `ProfileStatsData` model established; fetched from `v_profile_stats` view
- `UserService` wired: fetchCurrentUser (get_profile RPC) + fetchProfileStats (view query) read live DB
- Self-profile displays real name/department/icons/stats from DB (login → Profile verified end-to-end)
- Other-profile + Kudos board still mock; Supabase API for Kudo ops / Secret Box / Notifications deferred to Phase 7

---

## Phase 7 — Supabase API Integration (Kudo WRITE + interact + Secret Box + Notifications)
**Status: In Progress (READ ✓ Batch 3, WRITE ✓ Batch 4, interact/viewKudo ✓ Batch 5, Secret Box ✓ Batch 6; Notifications pending)**

**Completed (2026-06-01, Batch 4):** Kudos WRITE (sendKudo + kudo_hashtags) + search/user-fetch wired to live DB.
- `KudoService.sendKudo(title, message, recipientId, hashtags, senderAnon)` inserts kudo + junction entries; live verified
- `KudoService.listHashtags()` reads live hashtags table
- `UserService.fetchUser(userId)` + `searchSunners(query)` read live profiles + dept; verified end-to-end
- `SendKudoViewModel` wired to live flow; `FeatureFlags.useMockKudoData = false`
- Build: SUCCEEDED · Review: 0-critical · End-to-end: compose → send inserts real kudo (appears on feed)

**Completed (2026-06-01, Batch 5):** react/unreact + viewKudo + comments wired to live DB.
- `view_kudo(p_id)` RPC added; `list_kudos` extended with `has_reacted`; `kudo_json` internal helper (non-callable)
- `SupabaseRESTClient.delete(_:query:)` added
- `KudoService.react` / `unreact` live; `KudoService.viewKudo` live
- Optimistic toggle with in-flight guard + rollback in board and detail ViewModels
- Kudo detail shows real comments (read-only)
- Build: SUCCEEDED · Review: DONE · End-to-end verified

**Completed (2026-06-01, Batch 6):** Secret Box live + gamification EXECUTE security hardening.
- `SecretBoxService.currentBox()` reads `secret_boxes` (closed count) via REST; live
- `SecretBoxService.openBox(id:)` calls `open_secret_box(p_box_id)` RPC; DB function owns icon upsert; client reads returned `won_value_icon`; live
- Migration `20260601001200`: EXECUTE revoked on `grant_national_kudos` (public/anon/authenticated), `open_secret_box` (public/anon), and 6 trigger/helper functions — closes systemic privilege-escalation gap
- Dev seed: 5 closed boxes for `sunner@sun.com`
- Build: SUCCEEDED · Security hardening: DONE

**Remaining (Batch 7+):** notifications + comment submission.
- `NotificationService`: listNotifications, markRead, unreadCount
- `KudoService`: spotlight/personalStats/giftRecipients; comment submission (`addComment`)
- Board hashtag/department filters (server-side RPC ready, UI wiring deferred)
- Known issues: sendKudo non-transactional (consider `perform_send_kudo` RPC before prod); Kudo.title not rendered in card
