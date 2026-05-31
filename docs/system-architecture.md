# System Architecture

**Platform:** iOS 26.2+ · **Swift:** 5.0+ · **UI:** SwiftUI only · **Backend:** Supabase (stubbed, pending SDK wiring)

---

## Layer Overview

```
App/                AppRouter — single source of truth for navigation
Config/             SupabaseConfig, AppConstants
Models/             Pure Swift structs/enums (no business logic)
Services/           @MainActor singletons — all Supabase calls; typed LocalizedError enums
ViewModels/         @Observable @MainActor — state + calls to Services
Views/
  Containers/       Composition roots — own @State ViewModel, map state → presentational view,
                    dispatch actions, route via AppRouter (see §Container Layer)
  <Feature>/        Presentational SwiftUI views — props/callbacks only, no ViewModel or service imports
  Shared/           MainTabView (tab roots), NavDestinationResolver, shared components
Extensions/         Shared Swift extensions (Color+Hex, etc.)
```

Pattern: **MVVM + Container + Router + Service**

---

## Container Layer

Introduced in phase 19. Each `*Container` in `Views/Containers/` is the single composition root for one screen:

- Owns an `@State private var vm = <Feature>ViewModel()` — ViewModel lifetime is tied to the container.
- Reads ViewModel state and maps it to the presentational view's props.
- Handles callbacks by calling ViewModel methods or pushing to `AppRouter.path`.
- Surfaces loading/error states via shared `ContainerErrorView`.

`MainTabView` places the three tab-root containers (`KudosBoardContainer`, `NotificationsContainer`, `ProfileSelfContainer`) and registers a single `navigationDestination(for: NavDestination.self)` block that delegates to `NavDestinationResolver` — a private view that switches over all `NavDestination` cases and returns the appropriate container.

Presentational views (`Views/<Feature>/`) remain dumb: they accept typed props and fire callbacks; they never import a ViewModel or Service.

---

## Navigation

`AppRouter` (ObservableObject, @EnvironmentObject) owns two state fields:

| Field | Type | Purpose |
|---|---|---|
| `currentRoute` | `AppRoute` | Top-level auth gate (login / home / error) |
| `path` | `[NavDestination]` | In-app push stack inside the tab shell |

`AppRoute` values: `.login`, `.home`, `.error(AppErrorKind)`  
`AppErrorKind`: `.accessDenied` (403), `.notFound` (404)  
`NavDestination` covers all in-app destinations (profile, kudos board, send kudo, awards, secret box, community standards, notifications, search).

---

## Domain Models

| Model | Notes |
|---|---|
| `User` | Sunner profile |
| `Department` | Org unit |
| `Hashtag` | Kudo tag |
| `Award` / `AwardType` | Recognition awards |
| `Kudo` | Core kudos entity; anonymity enforced at model level |
| `KudoComment` | Comment on a kudo |
| `AppNotification` | In-app notification |
| `SecretBox` / `Gift` | Secret box feature |
| `ContentSection` / `CommunityStandard` / `Rule` | Static content |

---

## Services

All services follow the same contract: `@MainActor final class`, `static let shared`, typed `LocalizedError` enum, `async throws` methods. Currently stubbed — Supabase calls are TODO comments.

| Service | Domain |
|---|---|
| `AuthService` | Sign-in, session, OAuth |
| `UserService` | Profile fetch/update |
| `KudoService` | List, send, view kudos; list hashtags |
| `AwardService` | List awards by type |
| `NotificationService` | List, mark-read notifications |
| `SecretBoxService` | Fetch/send secret box gifts |
| `ContentService` | Static content sections, community standards, rules |

---

## ViewModels

One ViewModel per screen. All `@Observable @MainActor final class`. Bound via `@State` in the owning View.

`LoginViewModel`, `KudosBoardViewModel`, `AllKudosViewModel`, `ViewKudoViewModel`, `SendKudoViewModel`, `SearchSunnerViewModel`, `ProfileViewModel`, `AwardsViewModel`, `NotificationsViewModel`, `SecretBoxViewModel`, `ContentViewModel`

---

## Status

Track B (models, services, ViewModels, navigation) — complete, compiles on iOS 26.2 sim.  
Track A (UI screens) — complete (14 presentational SwiftUI screens).  
Phase 19 (integration) — complete; 13 container views wired, nav graph fully resolved, loading/error states handled.  
App is UI-complete. Supabase integration — stubbed; all service methods return empty/throw placeholder errors. Real data wiring is pending SDK installation.
