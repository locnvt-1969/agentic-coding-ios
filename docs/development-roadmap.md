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

## Phase 5 — Kudos Screen
**Status: In Progress**

- `KudosBoardView` + sub-sections: `SpotlightBoardSection` (388 Kudos stat, chart image, non-functional search), `KudosStatsBlock` (personal received/sent counts, heart + x2-fire badge, Secret Box opened/unopened), `GiftRecipientsList` (Top-10 gift recipients)
- `KudosStats`, `GiftRecipient` models added
- `KudoService+Mock.swift` — mock data extension (temporary; surgical swap to Supabase API pending SDK wiring)
- "Mở Secret Box" button wired to Secret Box flow via `AppRouter`; Spotlight search / Top-10 tap / heart = visual-only this pass
- Build: SUCCEEDED · Review: 8.2/10 approved

---

## Phase 6 — Profile Screen
**Status: Complete (mock data layer)**

- `ProfileSelfView` + `ProfileOtherView` wired with mock data
- `SunValueIcon` collection rendering with dynamic labels
- `ProfileStatsData` model established (5/25/25/25/25 stats)
- Spam-tagged kudos display implemented
- All service mocks in place; Supabase API wiring deferred to Phase 7

---

## Phase 7 — Supabase Swift SDK Integration
**Status: Not started**

Prerequisite for live Google OAuth. Add via SPM, then replace `AuthService` stubs.
