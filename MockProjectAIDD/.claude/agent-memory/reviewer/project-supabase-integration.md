---
name: project-supabase-integration
description: Supabase REST API integration for iOS SwiftUI app — batch status, key patterns, and known deferred items
metadata:
  type: project
---

Supabase REST integration uses a thin `SupabaseRESTClient` actor (no SDK) with JWT stored in UserDefaults (dev-only). `useMockKudoData=false` activates live send path; only `SendKudoViewModel` reads this flag.

**Why:** Dev build targets local Supabase instance; SDK integration deferred to production.

**How to apply:** When reviewing future batches, check whether JWT is moved to Keychain, whether react/unreact and viewKudo are wired (deferred), and whether two-step insert for kudos+hashtags has been made atomic via DB transaction or compensating delete.

## Known deferred items (next batch)
- react/unreact kudo
- viewKudo real fetch (currently uses `Self.mockKudos`)
- SecretBox open
- Notifications live path (`useMockNotifications=true`)
- JWT storage → Keychain migration
- `sendKudo` non-transactional two-step insert (accepted risk)
- `ProfileOtherContainer` `.sendKudo` push does not pre-populate recipient from viewed profile (UX gap, not bug)
