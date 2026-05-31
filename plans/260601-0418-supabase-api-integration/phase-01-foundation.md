# Phase 01 — Foundation (SDK + client + config + RPC)

**Priority:** Blocking · **Status:** pending · **Depends:** —

## Goal
Set up the Supabase Swift SDK, a shared client, config verification, the OAuth URL scheme, DTO conventions, and a `get_profile` RPC — the base every later phase builds on.

## Steps
1. **Add Supabase Swift SDK** via SPM: `https://github.com/supabase/supabase-swift` (product `Supabase`). Verify it resolves + app still builds.
2. **Register URL scheme** in Xcode (Project → Info → URL Types): `com.mockprojectaidd` (for OAuth redirect `com.mockprojectaidd://login-callback`).
3. **`Services/SupabaseClientProvider.swift`** (new): single `SupabaseClient(supabaseURL:supabaseKey:)` from `SupabaseConfig`. All services read `SupabaseClientProvider.shared.client`. ViewModels never import Supabase.
4. **Verify keys**: run a smoke read (`awards`) through the SDK + confirm `SupabaseConfig.anonKey` is accepted by the running local instance; if rejected, update to the key from `supabase status` (legacy JWT) — keep "safe to commit (local)" note.
5. **DB: `get_profile(p_id uuid)` RPC** (new migration `20260601000800_get_profile_rpc.sql`): returns `json` with profile + department + hero tier (`v_user_hero_tier`) + collected `value_icons` + stats (`v_profile_stats`) in one call. `security definer`, `grant execute to authenticated, anon`.
6. **DTO base convention**: `JSONDecoder` with `.convertFromSnakeCase`; document the DTO→model mapping rule for later phases.

## Files
- create: `Services/SupabaseClientProvider.swift`, `supabase/migrations/20260601000800_get_profile_rpc.sql`
- modify: `Config/SupabaseConfig.swift` (key check), Xcode project (SPM + URL scheme)

## Success criteria
- App builds with SDK linked; `SupabaseClientProvider.shared` initializes.
- `get_profile` RPC applies via `supabase db reset` and returns JSON for a sample profile.
- A smoke `awards` read via the client returns the 3 seeded rows.
