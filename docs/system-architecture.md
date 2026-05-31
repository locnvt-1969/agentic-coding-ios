# System Architecture

**Platform:** iOS 26.2+ · **Swift:** 5.0+ · **UI:** SwiftUI only · **Backend:** Supabase (stubbed, pending SDK wiring)

---

## Layer Overview

```
App/           AppRouter — single source of truth for navigation
Config/        SupabaseConfig, AppConstants
Models/        Pure Swift structs/enums (no business logic)
Services/      @MainActor singletons — all Supabase calls; typed LocalizedError enums
ViewModels/    @Observable @MainActor — state + calls to Services
Views/         SwiftUI views grouped by feature — presentational only, no service calls
Extensions/    Shared Swift extensions (Color+Hex, etc.)
```

Pattern: **MVVM + Router + Service**

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
Supabase integration — stubbed; all service methods return empty/throw placeholder errors.
