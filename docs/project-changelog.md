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

### Pending
- Track A: UI screens (in progress)
- Supabase SDK wiring (all service methods currently stubbed)
- Track A + Track B integration
