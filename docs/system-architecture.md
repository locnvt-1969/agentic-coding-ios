# System Architecture

**Platform:** iOS 26.2+ · **Swift:** 5.0+ · **UI:** SwiftUI only · **Backend:** Supabase (stubbed, pending SDK wiring)

---

## Layer Overview

```
App/                AppRouter — single source of truth for navigation
Config/             SupabaseConfig, FeatureFlags, AppConstants
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

`MainTabView` places the four tab roots — `HomeContainerView` (Home tab), `AwardDetailContainer` (Awards), `KudosBoardContainer` (Kudos), `ProfileSelfContainer` (Profile) — and registers a single `navigationDestination(for: NavDestination.self)` block that delegates to `NavDestinationResolver` — a private view that switches over all `NavDestination` cases and returns the appropriate container.

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

The bottom tab bar is owned by `MainTabView`; individual screens (including Home) do not render their own tab bar.

---

## Domain Models

| Model | Notes |
|---|---|
| `User` | Sunner profile |
| `Department` | Org unit |
| `Hashtag` | Kudo tag |
| `Award` / `AwardType` | Recognition awards |
| `Kudo` | Core kudos entity; anonymity enforced at model level; `isSpam: Bool` field drives Spam badge |
| `KudoComment` | Comment on a kudo |
| `AppNotification` | In-app notification |
| `SecretBox` / `Gift` | Secret box feature |
| `ContentSection` / `CommunityStandard` / `Rule` | Static content |
| `CountdownValue` / `AwardItem` / `HomeTab` | Home screen presentation models |
| `SunValueIcon` | Enum of 6 Sun* value icons (collected via Secret Boxes); shared by Profile badge strip and Rules screen |
| `ProfileStatsData` | Profile statistics card model (kudos received/sent, hearts, secret boxes); returned by `UserService.fetchProfileStats` |
| `KudosStats` | Personal kudos statistics (received, sent, hearts, secret box counts); Kudos board ALL KUDOS block |
| `GiftRecipient` | Top-10 gift recipient entry for Kudos board |

---

## Services

Domain services follow the same contract: `@MainActor final class`, `static let shared`, typed `LocalizedError` enum, `async throws` methods. Currently stubbed — Supabase calls are TODO comments.

**Mock extension pattern:** where temporary mock data is needed before Supabase wiring, it lives in a separate `<Service>+Mock.swift` extension file (e.g. `KudoService+Mock.swift`). The primary service file is unchanged; swapping to real API calls is surgical — replace the mock return with a Supabase call in the extension or primary file. This keeps mock data out of production service logic.

| Service | Domain |
|---|---|
| `AuthService` | Sign-in, session, OAuth |
| `UserService` | Profile fetch/update; `fetchProfileStats(userId:)` returns `ProfileStatsData` |
| `KudoService` | List, send, view kudos; list hashtags |
| `AwardService` | List awards by type (stubbed) |
| `NotificationService` | List, mark-read notifications |
| `SecretBoxService` | Fetch/send secret box gifts |
| `ContentService` | Static content sections, community standards, rules |

### Home feature — live runtime services

The Home screen ships with concrete (non-stubbed) services alongside the stubbed domain services above:

| Service | Singleton | Purpose |
|---|---|---|
| `AwardsService` | `AwardsService.shared` | Fetches `public.awards` via `URLSession` → Supabase REST (`GET /rest/v1/awards`). **Gated by `FeatureFlags.useMockAwards` (default `true`)** — when true, `HomeViewModel` loads from `HomeViewMockData` instead; the live REST path is preserved in the `else` branch. |
| `CountdownTimer` | per-ViewModel | 1-second tick toward target date sourced from `FeatureFlags` (`eventYear/Month/Day`; demo default 2026-06-28, real event 2025-12-26); exposes `CountdownValue`, `comingSoonVisible`, `eventEnded` |
| `ToastCenter` | `ToastCenter.shared` | Ephemeral overlay messages, auto-dismiss after 1.6 s; rendered by `ToastBannerView` at app root. `HomeViewModel` no longer uses `ToastCenter` — interactive CTAs now push real `NavDestination` via `AppRouter`. |

> `AwardsService` (Home, live REST) is distinct from `AwardService` (domain layer, stubbed list-by-type).

---

## ViewModels

One ViewModel per screen. All `@Observable @MainActor final class`. Bound via `@State` in the owning View.

`LoginViewModel`, `HomeViewModel`, `KudosBoardViewModel`, `AllKudosViewModel`, `ViewKudoViewModel`, `SendKudoViewModel`, `SearchSunnerViewModel`, `ProfileViewModel`, `AwardsViewModel`, `NotificationsViewModel`, `SecretBoxViewModel`, `ContentViewModel`

---

## Config

- `SupabaseConfig` — REST base URL (`http://localhost:54321`), anon key (default CLI key, safe to commit for local dev), `restURL` helper.
- `FeatureFlags` — compile-time flags; `isKudosAvailable: Bool` (default `true`) gates the Home Kudos section; `useMockAwards: Bool` (default `true`) gates Home awards data source (mock vs live REST); `useMockKudoData: Bool` (default `true`) gates Send Kudo recipients/hashtags/current-user + simulated submit (real `KudoService`/`UserService` path in `else` branch); `eventYear/Month/Day` constants drive `CountdownTimer` target date.

---

## Supabase Backend

Local instance: `http://localhost:54321`

| Table | Migration | Notes |
|---|---|---|
| `public.awards` | `supabase/migrations/20260529000000_create_awards.sql` | RLS enabled; anon-read policy |

Seed data: `supabase/seeds/awards.sql` (3 rows: Top Talent, Top Project, Top Manager).

**Backend transport:** Direct `URLSession` to Supabase REST (`/rest/v1`). The Supabase Swift SDK is NOT installed; `AuthService` Google sign-in is stubbed until SPM adds the SDK.

---

## Toast Pattern

`ToastCenter.shared.show(_:duration:)` queues a single ephemeral message. `ToastBannerView` (in the app-root `ZStack`) observes `ToastCenter.shared.message` and renders the overlay — visible on every route. Used for placeholder CTAs until destination screens are wired.

---

## Status

Track B (models, services, ViewModels, navigation) — complete, compiles on iOS 26.2 sim.  
Track A (UI screens) — complete (14 presentational SwiftUI screens + Home screen).  
Phase 19 (integration) — complete; 13 container views wired, nav graph fully resolved, loading/error states handled.  
Kudos board UI — Spotlight board, personal stats block, and Top-10 gift recipients sections added (+ header & hero); "Mở Secret Box" wired to router; mock data via `KudoService+Mock.swift`.  
App is UI-complete. Home awards load from mock data by default (`FeatureFlags.useMockAwards = true`); the live REST path exists but is not the default. Send Kudo screen is logic-complete on the mock path (`FeatureFlags.useMockKudoData = true`): validation, self-send guard, max-5-hashtags, cancel-confirm dialog, and success toast/pop are functional; rich-text toolbar, @mention, and image-upload remain visual-only. All other service methods are stubbed. Real data wiring is pending SDK installation.
