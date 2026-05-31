# Project Changelog

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

### Pending
- Supabase SDK wiring (all service methods currently stubbed)
- Phase 19: Track A + Track B integration (wire ViewModels/services into presentational screens)
