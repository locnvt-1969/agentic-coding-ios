# Project Changelog

## [Unreleased] — 2026-06-01

### Added — Send/Write Kudo screen logic (mock data path)

- `FeatureFlags` — new `useMockKudoData: Bool` (default `true`); when true, `SendKudoViewModel` loads mock recipients/hashtags/current-user and simulates submit; real `KudoService`/`UserService` path is preserved in the `else` branch
- `SendKudoMockData.swift` (`Views/Kudos/`) — bundled mock recipients, hashtags, current-user
- `KudoService.SendKudoPayload` — added `title` field
- `SendKudoViewModel` — title wiring, self-send guard (spec B.2), max-5-hashtags cap, full validation (recipient + title + message + ≥1 hashtag), simulated submit success; rich-text toolbar / @mention / image-upload remain visual-only
- `SendKudoContainer` — cancel-confirm dialog (spec H), "Community Standards" link wired (spec B.5), success toast + pop navigation on submit (TC_WRITE_FUN_001)

### Changed — Home screen logic wired to develop3 architecture

- `FeatureFlags` — added `useMockAwards` flag (default `true`) + `eventYear/Month/Day` countdown date constants (demo 2026-06-28; real event 2025-12-26)
- `CountdownTimer` — target date sourced from `FeatureFlags` (was hardcoded)
- `AwardType` — new `init(awardId:)` mapping backend award IDs → `AwardType` (`top-manager` → `.bestManager` fallback)
- `HomeViewModel` — 8 interactive CTAs now push real `NavDestination` via `AppRouter` (Search → `.searchSunner`, Bell → `.notifications`, About Award → `.awardDetail(.topTalent)`, About Kudos → `.kudosBoard`, Award card → `.awardDetail`, Kudos detail → `.kudosBoard`, FAB pencil → `.sendKudo`, FAB S/Kudos → `.allKudos`); `ToastCenter` dependency removed from `HomeViewModel`
- `HomeViewModel` — awards now load from `HomeViewMockData` when `FeatureFlags.useMockAwards` is true; live Supabase REST path preserved in the `else` branch
- `HomeContainerView` — passes `AppRouter` into nav closures

---

## [Unreleased] — 2026-05-30

### Added — Track B backbone (iOS Sun* Kudos app)

**Navigation**
- `AppRouter` with `AppRoute`, `AppErrorKind`, `NavDestination` enums; push/pop/popToRoot
- `MainTabView` shell
- `TopNavigationBar` shared component

**Models** (10)
- `User`, `Department`, `Hashtag`, `Award`, `AwardType`
- `Kudo` (anonymity enforced), `KudoComment`
- `AppNotification`
- `SecretBox`, `Gift`
- `ContentSection`, `CommunityStandard`, `Rule`

**Services** (6, stubbed Supabase, typed `LocalizedError` enums)
- `AuthService`, `UserService`, `KudoService`, `AwardService`, `NotificationService`, `SecretBoxService`, `ContentService`

**ViewModels** (10, `@Observable @MainActor`)
- `LoginViewModel`, `KudosBoardViewModel`, `AllKudosViewModel`, `ViewKudoViewModel`, `SendKudoViewModel`
- `SearchSunnerViewModel`, `ProfileViewModel`, `AwardsViewModel`, `NotificationsViewModel`, `SecretBoxViewModel`, `ContentViewModel`

### Added — Track A: UI screens (complete, all 14 MoMorph iOS screens)

**Feature clusters implemented as presentational SwiftUI views (no direct service calls):**
- **Error pages (phase 05):** `ErrorView` + `AccessDeniedView` / `NotFoundView` wrappers (403/404)
- **Language picker (phase 06):** `LanguagePickerView` thin wrapper over existing `LanguageDropdownView`
- **Notifications (phase 07):** `NotificationsView` with read/unread list
- **Profile — self (phase 08):** `ProfileSelfView` with awards, kudos, badges
- **Profile — other (phase 09):** `ProfileOtherView`
- **Award detail (phase 10):** `AwardDetailView`
- **Secret Box (phase 11):** `SecretBoxView`
- **Kudos board (phase 12):** `KudosBoardView`
- **All kudos (phase 13):** `AllKudosView` with filter
- **Send kudo (phase 14):** `SendKudoView`
- **View kudo (phase 15):** `ViewKudoView`
- **Search Sunner (phase 16):** `SearchSunnerView`
- **Community Standards (phase 17):** `CommunityStandardsView`
- **Rules (phase 18):** `RulesView`

**Reusable components introduced:**
- `KudoCard`, `FilterOverlay`, profile sub-views (`ProfileHeaderView`, `ProfileStatsView`, `ProfileTabsView`), `ProfileBadgeSlot`, `AwardVariantStyle`

### Added — Phase 19: Integration (iOS plan complete)

**Container layer** (`Views/Containers/`, 13 files)
- One `*Container` per screen: owns `@Observable` ViewModel via `@State`, maps VM state → presentational view props, dispatches actions, routes via `AppRouter`
- Containers: `KudosBoardContainer`, `AllKudosContainer`, `ViewKudoContainer`, `SendKudoContainer`, `SearchSunnerContainer`, `NotificationsContainer`, `ProfileSelfContainer`, `ProfileOtherContainer`, `AwardDetailContainer`, `SecretBoxContainer`, `CommunityStandardsContainer`, `RulesContainer`
- Shared `ContainerErrorView` for loading/empty/error states across all screens

**Navigation graph wired**
- `MainTabView` updated: tab roots use containers (`KudosBoardContainer`, `NotificationsContainer`, `ProfileSelfContainer`)
- `NavDestinationResolver` (private, in `MainTabView`) resolves all `NavDestination` cases to the correct container
- `ErrorView` route wired via `AppRoute.error(AppErrorKind)`

**ViewModel additions**
- `ProfileViewModel`: kudos count, awards count fields
- `SecretBoxView`: `onBack` callback added

**Plan status:** entire iOS Sun* Kudos app plan complete (Track B backbone + 14 Track A screens + phase 19 integration)

### Pending
- Supabase SDK wiring (all service methods currently stubbed; real data is future work)

---

## [Unreleased] — 2026-05-29

### Added — Home Screen (Phase 3)

**iOS**
- `HomeContainerView`, `HomeView` and sub-views: `HomeHeaderView`, `HomeHeroSection`, `HomeAwardsSection`, `HomeAwardCard`, `HomeKudosSection`, `HomeThemeSection`, `HomeBottomNavBar`, `HomeFAB`
- `HomeViewModel` (`@Observable`) — owns `AwardsLoadState` and drives awards fetch
- `AwardsService` — `URLSession` → Supabase REST `GET /rest/v1/awards?select=*&order=display_order.asc`
- `CountdownTimer` (`@Observable`) — 1-second tick toward 2025-12-26 00:00 Asia/Saigon; exposes `CountdownValue`, `comingSoonVisible`, `eventEnded`
- `ToastCenter` (`@Observable` singleton) + `ToastBannerView` — ephemeral overlay at app root, auto-dismisses after 1.6 s
- `HomeModels.swift` — `CountdownValue`, `AwardItem`, `HomeTab`
- `AwardsLoadState` enum — `idle / loading / loaded([AwardItem]) / empty / error(String)`
- `SupabaseConfig` — REST base URL (`http://localhost:54321`), anon key, `restURL` helper
- `FeatureFlags` — `isKudosAvailable: Bool` (compile-time, default `true`)

**Integration note (merge resolution)**
- Home is wired as the `.home` tab of the existing `MainTabView` shell (develop3 navigation architecture). The per-screen `HomeBottomNavBar` is superseded by the shared tab bar, so the standalone `.awards` / `.kudos` / `.profile` routes and their placeholder views are not part of the integrated navigation graph.

**Backend**
- Supabase migration `20260529000000_create_awards.sql` — `public.awards` table, RLS enabled, anon-read policy
- Seed `supabase/seeds/awards.sql` — 3 rows: Top Talent, Top Project, Top Manager

---

## [0.1.0] — 2026-05-28

### Added — Login Screen (Phase 2)

- `LoginView`, `LoginContainerView`, `LoginHeaderView`, `LoginGoogleButton`
- `LanguageDropdownView`, `AppLanguage` model
- `AuthService` — Google OAuth stub (Supabase Swift SDK not yet installed via SPM)
- `AppRouter` (`ObservableObject`) with `AppRoute.login` / `.home`
- `Color+Hex.swift` extension
- Initial Xcode project, MVVM + Router directory structure
