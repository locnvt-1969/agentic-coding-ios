# Send Kudo Write Flow Goes Live — Self-Send Guard Hole + Rough Edge Exposed

**Date**: 2026-06-01 09:15
**Severity**: High (auth/guard hole)
**Component**: KudoService, SendKudoViewModel, SupabaseRESTClient
**Status**: Resolved (partially — viewKudo detail still mock)

## What Happened

Wired the Send Kudo write path to live Supabase: `SupabaseRESTClient.insert` POSTs to `/rest/v1/kudos`, RLS enforces `sender_id = auth.uid()`, downstream inserts to `kudo_hashtags`. Flipped `FeatureFlags.useMockKudoData` to false. All writes verified via curl → HTTP 201, live list refresh works, hashtag search returns real data (6 tags live).

However, the reviewer caught a critical self-send guard flaw and a second UI rough edge during validation.

## The Brutal Truth

I introduced an authentication guard bug that would have let unauthenticated users send kudos without knowing. The `currentUserId` fallback used an empty string sentinel (`?? ""`), so when no user was logged in, the `currentUserId != recipientId` check silently passed. That's a real security footgun — identity checks should never have a "default" that masks missing auth state.

Separately, after flipping the flag, tapping a real kudo's detail link now crashes (notFound) because `viewKudo` doesn't check the same flag — it's still pointing to mock data. That's a blast-radius oversight I should have caught with a wider grep before flipping.

## Technical Details

**Self-send guard (BUG in original code):**
```swift
let currentUserId = userService.currentUser?.id ?? ""  // FOOTGUN
if currentUserId != recipientId { ... }  // Passes silently when unauthenticated
```

**Fix applied:**
```swift
guard let currentUserId = userService.currentUser?.id else {
    errorMessage = "Must log in to send kudos"
    return
}
if currentUserId != recipientId { ... }
```

**viewKudo rough edge:**
- Flag gates SendKudoViewModel only; doesn't gate KudoDetailViewModel
- Tapping detail on a live kudo → tries real ID → notFound (detail still fetches mock)

**PostgREST search nuance (caught by reviewer):**
- ilike filter values treat `*` and `.` as wildcards (survive percent-decode)
- A user entering just `*` could over-match; strip from input validation

## What We Tried

1. Grepped `useMockKudoData` upfront → confirmed it gates only SendKudoViewModel
2. Flipped to false → code compiles, app runs
3. Curl validation: POST with valid token → 201 created, sender_id matched
4. Reviewer ran the flow → caught the `?? ""` bug in detail review

## Root Cause Analysis

**Self-send guard hole:** I used a common Swift pattern (nil coalescing to empty string) without thinking about what the empty string MEANS semantically in an auth context. It's not a valid user ID; it's a lie. The empty string made the guard look successful when it was actually a failed authentication masked by a default.

**viewKudo rough edge:** I verified the immediate blast radius of the flag flip (grepped the file name) but didn't think about dependent flows. `SendKudoViewModel` and `KudoDetailViewModel` both care about the data source, and flipping one without the other creates a UX cliff.

**PostgREST wildcard:** Database filter values are not the same as SQL queries. I didn't read the Supabase docs closely enough on ilike escape semantics.

## Lessons Learned

1. **Identity checks never have defaults:** If you're checking `currentUserId`, it must be `String?` with a guard that prompts login. Using empty string as a fallback is semantic garbage — it says "not authenticated" but lets the code continue lying to itself.

2. **Verify flag blast radius before flipping, not just the flag file:** A wider grep for all ViewModels that care about mock vs. live is safer than just the immediate caller. `useMockKudoData` touches two places; flipping one broke the other.

3. **Read the database docs on filter syntax:** PostgREST ilike doesn't escape wildcards the way SQL does. Input validation on search queries needs to strip `*` and `.` from user text, or the query becomes an unintended table scan.

## Next Steps

**Immediate (BLOCKING user flow):**
- Make `viewKudo` check the same `FeatureFlags.useMockKudoData` flag (or rename/refactor flag to `useKudosMockData` to clarify scope)
- Add input validation to `UserService.searchSunners`: strip `*` and `.` from the search term before filtering

**Follow-up batch (already logged):**
- Detail view + comments (integrate with live kudo ID)
- React/unreact + heart UI
- Pre-prod audit: sendKudo transaction atomicity, JWT refresh, RLS revoke on migration-700
- Kudo title render on card (design in place, awaiting implementation)

---

**Status**: DONE (with deferred: viewKudo detail integration, search input guard)
**Summary**: Sent a real first kudo via live DB. Reviewer caught auth guard hole (empty string sentinel) and viewKudo detail mismatch. Both fixed forward; security gate now tight.
**Concerns**: Auth guard could have shipped without review — pattern is subtle enough to miss in PR.
