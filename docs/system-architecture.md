# System Architecture

**Platform:** iOS 26.2+ · **Swift:** 5.0+ · **UI:** SwiftUI only · **Backend:** Supabase (local GoTrue + PostgREST; no Swift SDK)

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
| `Kudo` | Core kudos entity; anonymity enforced at model level; `isSpam: Bool` field drives Spam badge; `title: String?` optional self-set heading |
| `KudoComment` | Comment on a kudo |
| `AppNotification` | In-app notification |
| `SecretBox` / `Gift` | Secret box feature |
| `ContentSection` / `CommunityStandard` / `Rule` | Static content |
| `CountdownValue` / `AwardItem` / `HomeTab` | Home screen presentation models |
| `SunValueIcon` | Enum of 6 Sun* value icons (collected via Secret Boxes); shared by Profile badge strip and Rules screen. Each case exposes a `dbId: String` (snake_case Supabase slug) and `init?(dbId:)` for decoding from `get_profile` payload |
| `ProfileStatsData` | Profile statistics card model (kudos received/sent, hearts, secret boxes); returned by `UserService.fetchProfileStats` |
| `KudosStats` | Personal kudos statistics (received, sent, hearts, secret box counts); Kudos board ALL KUDOS block |
| `GiftRecipient` | Top-10 gift recipient entry for Kudos board |

---

## Services

Domain services follow the same contract: `@MainActor final class`, `static let shared`, typed `LocalizedError` enum, `async throws` methods. Most domain services are still stubbed — Supabase calls are TODO comments — except where noted below.

**Mock extension pattern:** where temporary mock data is needed before Supabase wiring, it lives in a separate `<Service>+Mock.swift` extension file (e.g. `KudoService+Mock.swift`). The primary service file is unchanged; swapping to real API calls is surgical — replace the mock return with a Supabase call in the extension or primary file. This keeps mock data out of production service logic.

**Infrastructure:** `SupabaseRESTClient` (`actor`, `static let shared`) is the shared PostgREST transport. It executes `GET` requests, `callRPC` (POST `/rpc/<name>`), and `insert` (POST to a table with `Prefer: return=minimal`) with `apikey` + `Bearer` headers, snake_case → camelCase JSON decoding, and typed `SupabaseRESTError`. An `accessToken: String?` property (settable via `setAccessToken(_:)`) carries the user JWT when available; falls back to the anon key for public reads. PATCH/DELETE planned for later phases. All domain services that hit the real DB delegate to this client rather than constructing their own `URLRequest`.

| Service | Domain |
|---|---|
| `AuthService` | Sign-in, session, OAuth. **Phase 2 wired:** real email/password sign-in via GoTrue raw REST (`POST /auth/v1/token`); stores JWT in `UserDefaults`, calls `SupabaseRESTClient.shared.setAccessToken(_:)` so RLS sees `auth.uid()`. Dev: `signInWithGoogle()` signs in the seeded test account (`sunner@sun.com`); real Google OAuth deferred (prod, requires SDK). |
| `UserService` | Profile fetch/update; `fetchProfileStats(userId:)` returns `ProfileStatsData`. `ProfileDTO` (`Services/ProfileDTO.swift`) is the decode layer for the `get_profile(p_id)` Postgres RPC (composed JSON: profile + department + hero tier + collected value icons + stats; SECURITY DEFINER; `authenticated` only); maps to `User` + `ProfileStatsData` via `toUser()` / `toStats()`. **Phase 2 wired:** `fetchCurrentUser()` calls `get_profile` RPC via `callRPC`; `fetchProfileStats` queries `v_profile_stats` view — both read the live DB for the logged-in user. **`fetchUser(id:)` now live:** calls `get_profile` RPC for any user ID. **`searchSunners(query:)` now live:** `GET /rest/v1/profiles` with `full_name=ilike.*q*` and embedded `departments(name)` select. |
| `KudoService` | List, send, view kudos; list hashtags. `listAllKudos(page:)` and `listKudos(filter:)` (board feed) + `listReceivedKudos(userId:)` call the `list_kudos(p_limit, p_offset, p_recipient, p_sender)` Postgres RPC via `callRPC`; anonymity enforced by the `kudos_public` view server-side. `KudoDTO` (`Services/KudoDTO.swift`) is the decode layer (snake_case → `Kudo`). **`sendKudo(_:)` now live:** inserts into `kudos` then `kudo_hashtags` via `SupabaseRESTClient.insert`. **`listHashtags()` now live:** `GET /rest/v1/hashtags`. `viewKudo`, `spotlightTotalKudos`, `fetchPersonalStats`, `listGiftRecipients` remain stubbed. |
| `AwardService` | List awards by type (stubbed) |
| `NotificationService` | List, mark-read notifications |
| `SecretBoxService` | Fetch/send secret box gifts |
| `ContentService` | `communityStandards()` and `rules()` fetch `content_sections` from the live local Supabase via `SupabaseRESTClient`; in-memory fallback removed |

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

- `SupabaseConfig` — REST base URL (`http://localhost:54321`), anon key (default CLI key, safe to commit for local dev), `restURL` helper, `authURL` (`/auth/v1`) for GoTrue calls.
- `FeatureFlags` — compile-time flags; `isKudosAvailable: Bool` (default `true`) gates the Home Kudos section; `useMockAwards: Bool` (default `true`) gates Home awards data source (mock vs live REST); `useMockKudoData: Bool` (**now `false`**) — Send Kudo flow uses live `KudoService.sendKudo` / `listHashtags` and `UserService.searchSunners` / `fetchUser`; `useMockNotifications: Bool` (default `true`) gates Notifications screen mock data + local-only mark-read (real `NotificationService` path in `else` branch); `eventYear/Month/Day` constants drive `CountdownTimer` target date.

---

## Supabase Backend

Local instance: `http://localhost:54321`

| Table | Migration | Notes |
|---|---|---|
| `public.awards` | `supabase/migrations/20260529000000_create_awards.sql` | RLS enabled; anon-read policy |
| `public.content_sections` | — | Stores static document rows (columns: `document_id`, `display_order`, plus content fields); queried by `ContentService` filtered on `document_id` (`community_standards`, `rules`) |

Seed data: `supabase/seeds/awards.sql` (3 rows: Top Talent, Top Project, Top Manager).

**Backend transport:** `SupabaseRESTClient` (`actor`) provides a shared PostgREST GET layer over `URLSession`. All REST-connected services use it. The Supabase Swift SDK is NOT installed; `AuthService` Google sign-in is stubbed until SPM adds the SDK.

---

## Toast Pattern

`ToastCenter.shared.show(_:duration:)` queues a single ephemeral message. `ToastBannerView` (in the app-root `ZStack`) observes `ToastCenter.shared.message` and renders the overlay — visible on every route. Used for placeholder CTAs until destination screens are wired.

---

## Status

Track B (models, services, ViewModels, navigation) — complete, compiles on iOS 26.2 sim.  
Track A (UI screens) — complete (14 presentational SwiftUI screens + Home screen).  
Phase 19 (integration) — complete; 13 container views wired, nav graph fully resolved, loading/error states handled.  
Kudos board UI — Spotlight board, personal stats block, and Top-10 gift recipients sections added (+ header & hero); "Mở Secret Box" wired to router; mock data via `KudoService+Mock.swift`.  
Notifications screen — mock data complete (`FeatureFlags.useMockNotifications = true`); 7 notification kinds with tap-to-mark-read and mark-all-read; `contentHidden` links to Community Standards; per-type deep navigation deferred.  
App is UI-complete. **Supabase API integration Increment 1 complete:** `SupabaseRESTClient` (shared actor) provides the reusable PostgREST GET transport; `ContentService` (`communityStandards()` + `rules()`) reads the live `content_sections` table — the first domain service beyond `AwardsService` to use the real DB. Home awards load from mock data by default (`FeatureFlags.useMockAwards = true`); the live REST path exists but is not the default. Send Kudo screen is logic-complete on the mock path (`FeatureFlags.useMockKudoData = true`): validation, self-send guard, max-5-hashtags, cancel-confirm dialog, and success toast/pop are functional; rich-text toolbar, @mention, and image-upload remain visual-only. **Supabase API integration Increment 2 complete (auth-independent groundwork):** `get_profile(p_id)` Postgres RPC added (SECURITY DEFINER, `authenticated`-only; returns composed JSON: profile + department + hero tier + collected value icons + stats). `ProfileDTO` decode layer (`Services/ProfileDTO.swift`) maps RPC output to `User` + `ProfileStatsData`. `SunValueIcon` extended with `dbId` / `init?(dbId:)` for DB slug mapping. `Kudo` model gains optional `title: String?` field.  
**Supabase API integration Phase 2 (Auth + self-profile) complete:** `AuthService` does real GoTrue email/password sign-in; JWT stored and propagated to `SupabaseRESTClient` (RLS active). `SupabaseRESTClient` gained `callRPC` (POST `/rpc`). `UserService.fetchCurrentUser` (via `get_profile` RPC) and `fetchProfileStats` (via `v_profile_stats` view) both read the live DB for the authenticated user. Dev test account (`sunner@sun.com`) seeded locally. All other service methods remain stubbed. POST/PATCH/DELETE planned for later increments.
**Supabase API integration — Kudos READ batch complete:** `list_kudos(p_limit, p_offset, p_recipient, p_sender)` Postgres RPC added; composes kudos JSON from the `kudos_public` view (anonymity enforced there), caps page size, supports optional recipient/sender filters. `KudoDTO` (`Services/KudoDTO.swift`) is the new decode layer mapping RPC output to `Kudo`. `KudoService.listAllKudos` / `listKudos` (board feed) and `listReceivedKudos(userId:)` now read the live DB via this RPC. `ProfileViewModel` kudos section wired to `listReceivedKudos`; received/sent counts sourced from real profile stats. `KudoService+Mock.swift` still supplies mock data for sections not yet wired (viewKudo, spotlight, personal stats, gift recipients).
**Supabase API integration — Send Kudo + search/hashtags batch complete:** `SupabaseRESTClient` gained `insert(table:values:)` (POST, `Prefer: return=minimal`). `KudoService.sendKudo` inserts into `kudos` then `kudo_hashtags`; `KudoService.listHashtags` reads live `hashtags` table. `UserService.fetchUser(id:)` calls `get_profile` RPC; `UserService.searchSunners(query:)` queries `profiles` with `ilike` + embedded `departments`. `FeatureFlags.useMockKudoData` set to `false` — Send Kudo flow is fully live. Remaining stubbed: `viewKudo`, `spotlightTotalKudos`, `fetchPersonalStats`, `listGiftRecipients`.

**UI scroll pattern (full-screen content screens):** `safeAreaInset(.top)` + background keyvisual + `toolbar(.hidden)` is the established pattern for screens that render a custom header with a background image extending behind the status bar. Applied to: `NotificationsView`, `CommunityStandardsView`, `RulesView`. The `.ignoresSafeArea(.top)` approach is deprecated for these screens.
