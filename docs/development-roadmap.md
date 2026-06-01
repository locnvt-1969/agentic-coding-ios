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

## Phase 5 — Kudos Screen (READ API wired)
**Status: In Progress (READ path live; WRITE/interact pending)**

- `KudosBoardView` + sub-sections: `SpotlightBoardSection` (388 Kudos stat, chart image, non-functional search), `KudosStatsBlock` (personal received/sent counts, heart + x2-fire badge, Secret Box opened/unopened), `GiftRecipientsList` (Top-10 gift recipients)
- `KudosStats`, `GiftRecipient` models added
- `KudoService` — `listAllKudos(page)` + `listKudos()` + `listReceivedKudos(userId)` wired to live `list_kudos` RPC (DB); mock extension removed
- `ProfileViewModel` — kudos property reads RECEIVED kudos; received/sent counts from live `v_kudos_stats` view
- Board feed, All Kudos, Profile kudos sections show real DB data (anonymity, hashtags, hearts, dates correct)
- Build: SUCCEEDED · Review: 7/10 0-critical · End-to-end verified (curl + Kudos board screenshot)
- **Known follow-ups:** Spotlight search / Top-10 tap / heart button remain visual-only (sendKudo/react/viewKudo in Phase 7); board hashtag/dept filters not wired (UI ignores); Kudo.title rendering in KudoCard deferred (P6)

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

## Phase 7 — Supabase API Integration (Kudo WRITE + Secret Box + Notifications)
**Status: In Progress (READ ✓ Batch 3, WRITE ✓ Batch 4; react/Secret Box/Notifications pending)**

**Completed (2026-06-01, Batch 4):** Kudos WRITE (sendKudo + kudo_hashtags) + search/user-fetch wired to live DB.
- `KudoService.sendKudo(title, message, recipientId, hashtags, senderAnon)` inserts kudo + junction entries; live verified
- `KudoService.listHashtags()` reads live hashtags table
- `UserService.fetchUser(userId)` + `searchSunners(query)` read live profiles + dept; verified end-to-end
- `SendKudoViewModel` wired to live flow; `FeatureFlags.useMockKudoData = false`
- Build: SUCCEEDED · Review: 0-critical · End-to-end: compose → send inserts real kudo (appears on feed); search → real users; other-profile → real data (verified)

**Remaining user-context services (Batch 5+):** react/unreact + viewKudo + secret box + notifications.
- `KudoService`: viewKudo (detail + comments), react/unreact, spotlight/personalStats/giftRecipients
- `SecretBoxService`: currentBox, openBox
- `NotificationService`: listNotifications, markRead, unreadCount
- Board hashtag/department filters (server-side RPC ready, UI wiring deferred to P6)
- Known issues: viewKudo still mock (tapping real kudo errors notFound); sendKudo non-transactional (hashtag insert failure doesn't roll back kudo); Kudo.title not rendered in card
