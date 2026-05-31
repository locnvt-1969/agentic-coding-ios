# Code Standards

Platform: iOS 26.2+, Swift 5.0+, SwiftUI only.

---

## Naming Conventions

| Type | Pattern | Example |
|------|---------|---------|
| View | `<Feature>View` | `LoginView`, `HomeView` |
| Container View | `<Feature>ContainerView` | `HomeContainerView` |
| ViewModel | `<Feature>ViewModel` | `HomeViewModel`, `LoginViewModel` |
| Service | `<Domain>Service` | `AuthService`, `AwardsService` |
| Router | `AppRouter` | — |
| Config enum | `<Name>Config` | `SupabaseConfig` |
| Feature flags | `FeatureFlags` | — |
| Extension file | `<Type>+<Capability>.swift` | `Color+Hex.swift` |
| Error enum | `<Domain>Error` | `AuthError`, `AwardsError` |
| Model file | `<Feature>Models.swift` | `HomeModels.swift` |
| Load-state enum | `<Domain>LoadState` | `AwardsLoadState` |

File names: match the primary type they define (PascalCase, `.swift`).

---

## File Size

- Hard limit: 200 lines per file.
- Split into sub-views or helper files before hitting the limit.
- Sub-views for a feature live in `Views/<Feature>/`.

---

## Architecture Rules

- **Views are dumb.** Accept props/callbacks; no direct service calls.
- **ViewModels own state** and call Services.
- **Services are singletons** (`static let shared`), marked `@MainActor final class`.
- **AppRouter** is the single source of truth for navigation. Never use `NavigationPath` for auth routing.
- **Extensions** go in `Extensions/`. Never define shared extensions inside a feature file.

---

## State Management

Prefer `@Observable` (iOS 17+) for new ViewModels:

```swift
import Observation

@Observable
final class ExampleViewModel {
    var isLoading = false
    var errorMessage: String?
}
// View: @State private var viewModel = ExampleViewModel()
```

Use `ObservableObject` + `@Published` only when `@EnvironmentObject` is required (e.g. `AppRouter`) or when integrating with existing `ObservableObject` code in the same file.

Never mix `@StateObject` with `@Observable` — use `@State` instead.

---

## Async / Concurrency

- Use `async/await` and `Task {}`. No Combine for new code.
- All UI state updates on `@MainActor`. Mark ViewModels `@MainActor final class`.
- Double-click / re-entrancy guard:

```swift
private var isInFlight = false
func doAction() async {
    guard !isInFlight else { return }
    isInFlight = true
    defer { isInFlight = false }
    // ...
}
```

---

## Error Handling

- Use typed error enums conforming to `LocalizedError`.
- User-cancelled actions (`.signInCancelled`) → `errorDescription` returns `nil` → no alert shown.
- Network/auth failures → `.alert` dialog surfaced by the View.
- No `fatalError` or `try!` in production paths.
- No force unwrap (`!`). Use `guard let` / `if let` / `?? default`.

---

## Config & Constants

- No magic strings. Use enums or constants.
- Supabase URL/key: `SupabaseConfig` only. Never hardcode in Views or ViewModels.
- Feature flags: `FeatureFlags` compile-time enum.

---

## Supabase Integration

- `AuthService` wraps all auth calls. ViewModels and Views never import Supabase directly.
- Backend transport: `SupabaseRESTClient` (`actor`, `static let shared`) — the canonical PostgREST client. Use it in new services; do not construct raw `URLRequest` + `URLSession` inline. No Supabase Swift SDK currently. Supports `GET` queries and `callRPC` (POST `/rpc/<name>`) for Postgres functions.
- `AuthService.signIn(email:password:)` calls GoTrue (`POST /auth/v1/token`), persists the JWT, and calls `SupabaseRESTClient.shared.setAccessToken(_:)` — RLS sees `auth.uid()` from that point. Sign-out calls `setAccessToken(nil)`.
- Services that need authenticated reads rely on the token set by `AuthService`; the client falls back to the anon key for unauthenticated reads.
- OAuth redirect URL scheme: `com.mockprojectaidd://login-callback` — must be registered in Xcode project Info → URL Types.

---

## Load-State Pattern

For async data sections, use a typed load-state enum:

```swift
enum <Domain>LoadState: Equatable {
    case idle
    case loading
    case loaded([Model])
    case empty
    case error(String)
}
```

Drive the View `switch` directly off this enum. See `AwardsLoadState` as the reference implementation.

---

## Toast Pattern

Surface placeholder/feedback messages via `ToastCenter.shared.show(_:)`. Do not create per-view toast state. `ToastBannerView` in the app root handles display.
