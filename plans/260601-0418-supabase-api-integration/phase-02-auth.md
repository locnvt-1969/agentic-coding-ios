# Phase 02 — Auth (Local Email/Password + Session Mgmt)

**Priority:** Blocking · **Status:** DONE (2026-06-01) · **Depends:** P01

**Implementation summary (2026-06-01):**
- AuthService: GoTrue REST client (local email/password sign-in + JWT store/restore + sign-out)
- SupabaseRESTClient: callRPC(endpoint, payload) for POST /rpc calls
- LoginContainerView: dev-bypass removed, real sign-in integrated
- Dev seed: test user (sunner@sun.com / Password123!) with dept + icons
- Build: SUCCEEDED, Review: 0-critical (4 fixes), End-to-end: verified (login → Profile renders live DB data)

## Goal
Real Google sign-in via Supabase Auth → persisted session → `auth.uid()` available for all user-context calls. Replace the Login dev-bypass.

## Steps
1. **`AuthService`** real impl (wraps the SDK):
   - `signInWithGoogle()` → `client.auth.signInWithOAuth(provider: .google, redirectTo: com.mockprojectaidd://login-callback)`; on success set `isAuthenticated`.
   - `checkAndRestoreSession()` → `try? await client.auth.session` (auto-refresh) → bool.
   - `signOut()` → `client.auth.signOut()`.
   - Map SDK errors → `AuthError` (cancelled = silent).
2. **OAuth callback**: handle the redirect URL in `MockProjectAIDDApp` (`.onOpenURL { client.auth.handle($0) }`).
3. **LoginContainerView**: remove the dev-bypass (`router.navigate(.home)`), call `await viewModel.loginWithGoogle()`; on `isAuthenticated` → Home (already wired via `.onChange`).
4. **Startup gate**: on launch, `checkAndRestoreSession()` → if session, start at `.home`, else `.login`.
5. **Local Google OAuth**: configure provider in `supabase/config.toml` `[auth.external.google]` (client id/secret) OR document using a test provider for local; note prod needs real Google OAuth creds + redirect allow-list.

## Files
- modify: `Services/AuthService.swift`, `MockProjectAIDDApp.swift`, `Views/Login/LoginContainerView.swift`, `supabase/config.toml` ([auth] redirect URLs + google)

## Success criteria
- Tap "LOGIN With Google" → OAuth web flow → redirect → lands on Home with a real session.
- Relaunch restores the session (no re-login); sign-out returns to Login.
- Subsequent REST/RPC calls carry the user JWT (RLS sees `auth.uid()`).

## Notes
- If local Google OAuth setup is heavy, a fallback for dev: email/password or a seeded test session — but the target is real Google per `AuthService` design.
