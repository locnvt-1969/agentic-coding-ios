# Phase 06 — UI/ViewModel wiring + integration & verify

**Priority:** High · **Status:** pending · **Depends:** P04, P05

## Goal
Connect the new service behaviors into ViewModels/Views, remove mock fallbacks, and verify the full app against local Supabase.

## Steps
1. **Reactions UI**: add a tappable heart in `KudoCard` (+ View Kudo) → `react/unreact`; reflect `hasReacted` + live `reactionCount`. Update `KudosBoardViewModel` / `AllKudosViewModel` / `ViewKudoViewModel`.
2. **Send Kudo flow**: `SendKudoViewModel.submit` → `KudoService.sendKudo`; recipient picker uses `searchSunners`; hashtags from `listHashtags`; success → pop + toast.
3. **Secret Box**: `SecretBoxViewModel` → `currentBox`/`openBox`; reveal the won icon.
4. **Profile**: `ProfileViewModel` consumes real `get_profile` (drop the mock from the earlier session); other-profile via `fetchUser`.
5. **Remove temporary mocks** added earlier (UserService/KudoService demo data, `ProfileMockData`-style) now that real data flows — keep `ContentService.figmaSample` only as preview fixture.
6. **Dev test data**: `supabase/seeds/dev/` + a script using the gotrue admin API (service key) to create 2–3 demo auth users; seed kudos/reactions so screens have content in local dev.
7. **Verify**: run app on simulator → login → exercise each screen; gamification E2E (heart→box→icon→reward, top-5→gift). Spawn `tester` (if tests added) + `reviewer` on the diff.

## Files
- modify: `Views/Kudos/KudoCard.swift`, kudos/profile/secretbox/notifications ViewModels, `ViewModels/ProfileViewModel.swift`, `Services/UserService.swift` + `KudoService.swift` (drop demo mocks)
- create: `supabase/seeds/dev/*.sql` + a dev user-seeding script

## Success criteria
- App runs end-to-end on real data: login → home → kudos board → send kudo → heart → secret box → profile (stats/hero/icons) → notifications.
- No stub `// TODO: Supabase` left in wired methods; build green; reviewer ≥ 9.0 / 0 critical.
