# Secret Box Feature + Gamification Security Hardening

**Date**: 2026-06-01 10:54  
**Severity**: High (security), Medium (feature completion)  
**Component**: SecretBoxService, gamification RPC functions, Supabase auth  
**Status**: Resolved

## What Happened

Wired the Secret Box feature end-to-end: `SecretBoxService.currentBox()` queries unopened boxes and returns the count; `openBox()` fetches the oldest closed box, calls `open_secret_box` RPC (atomically picks a random unowned value icon, opens the box, adds icon to collection), and returns the won icon as a `Gift`. UI shows unopened count and reveals the prize via modal alert.

Simultaneously deployed a security hardening migration that revoked EXECUTE privilege on `grant_national_kudos` (end-of-program admin function), `open_secret_box` (anon surface only), and six trigger functions from public/anon/authenticated roles.

## The Brutal Truth

We shipped with a **privilege escalation hole** in production. Any authenticated user could call `grant_national_kudos()` directly via PostgREST and mint the end-of-program top-5 "Kudos Quốc Dân" rewards to themselves. This was flagged in two prior batches as a pre-production TODO. It took this batch to finally close it. That's embarrassing — not because the hole existed (Supabase defaults are permissive), but because we deferred the fix twice.

The craft lesson is painful: **Supabase auto-GRANTs EXECUTE to anon+authenticated on every new function**. `REVOKE ... FROM PUBLIC` alone doesn't revoke from named roles. We have to revoke explicitly from all three: public, anon, authenticated. Until this batch, I didn't verify that behavior — I assumed `REVOKE FROM PUBLIC` covered everything. It doesn't.

## Technical Details

**Migration:** `20260601001200_lock_gamification_functions.sql` (21 lines)
- `REVOKE EXECUTE ON function public.grant_national_kudos() FROM public, anon, authenticated;` — closes the escalation path
- `REVOKE EXECUTE ON function public.open_secret_box(uuid) FROM public, anon;` — keeps only authenticated callable
- Six trigger functions (SECURITY DEFINER): revoked from all three roles, kept off /rpc surface entirely

**Service:** `SecretBoxService.swift`
- `currentBox()`: GET `/secret_boxes?state=eq.closed&order=created_at.asc`, decode `[{ id }]`, return count
- `openBox()`: fetch oldest box, call open_secret_box RPC, decode `{ id?: null, label?: null }` response
- Critical detail: PostgREST returns null-field composites as objects with null fields, **never as JSON null**. This is not obvious. The field-nil guard (`guard let iconId = icon.id`) is the real gate; if all icons are owned, the RPC returns `{ id: null, label: null, ... }`

**ViewModel/View:** Added `availableCount` to SecretBox model + guard in ViewModel + binding to Container for count display.

## What We Tried

1. **Initial decode attempt**: tried optional `ValueIconRow?` with fallback — reviewer flagged as "dead code" (why decode to nil?). 
2. **Resolution**: tested empirically — gave the test user all 6 icons, opened a box, read the actual PostgREST response. Confirmed the object-with-nulls serialization. Removed optional, simplified to non-optional decode + field-nil guard.

## Root Cause Analysis

**The privilege gap:** Supabase's built-in default privileges are overly permissive for security-sensitive operations. When you create a function, the system auto-GRANTS EXECUTE to public, anon, and authenticated. The documentation warns about this, but it's easy to miss.

**Why we deferred twice:** The gap was flagged early but felt like "polish before prod" rather than blocking. No one had exploited it (internal testing only), so the pressure to close it faded. Classic risk-acceptance antipattern — we accepted a known-exploitable hole instead of fixing it upfront.

**Why `REVOKE FROM PUBLIC` failed us:** I assumed `PUBLIC` was a keyword covering all roles. It's not — `PUBLIC` is a catch-all for unauthenticated sessions only. Named roles (anon, authenticated) must be revoked explicitly. The correct pattern for a Supabase function is:
```sql
REVOKE EXECUTE ON FUNCTION public.sensitive_fn() FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.sensitive_fn() TO service_role; -- only this
```

**Trigger functions are safe to lock down:** They run as SECURITY DEFINER (the function owner), so revoking caller EXECUTE removes them from /rpc without breaking the trigger firing. Clean design.

## Lessons Learned

1. **Supabase privilege model is inverted from intuition.** Default is open; you close it. `REVOKE FROM PUBLIC` is only step one. Always explicitly revoke from anon and authenticated too.

2. **Empirical testing of API serialization beats guessing.** The null-field composite serialization isn't documented clearly. Firing the request and reading the actual response was faster and more reliable than speculating.

3. **Known security gaps should be fixed immediately, not deferred.** The escalation hole was flagged but deprioritized. Deferral cost us two batches and one nervous commit.

4. **Trigger functions don't need caller grants.** They're fired by the database, not the API. Keeping them entirely off /rpc surface (revoke from all roles) is the right pattern.

5. **YAGNI: don't decode unreachable states.** The DB enum `SecretBox.State` has a `case opened`, but the app only counts closed boxes. The decode never reaches it. Logged as technical debt, not added to the enum.

## Next Steps

1. **Audit all other gamification RPCs** for similar exposure — verify each has the correct role revokes in place
2. **Document the Supabase privilege pattern** in `docs/code-standards.md`: "Lock down all new functions by explicitly revoking from public, anon, authenticated"
3. **Update pre-prod checklist** to include function grant audit before staging

## Emotional Reality

Honestly, shipping a privilege escalation hole (even in a learning project) was a gut punch. The feature worked. The security issue was latent, not a crash. But the fact that we *knew* about it and deferred the fix twice stings. This is the kind of thing that turns into a post-mortem email if it hits production-with-real-users. Good lesson on saying "no" to feature pressure and clearing security TODOs before moving on.
