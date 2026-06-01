# Kudo Reactions & View Detail Implementation

**Date**: 2026-06-01 10:21
**Severity**: Medium
**Component**: Supabase RPC layer, Swift ViewModels, UI state management
**Status**: Resolved

## What Happened

Completed the second major feature batch for the Kudos board: kudo detail view, heart react/unreact with optimistic updates, and comment display. Commit 383c601 landed 25 file changes across DB migrations, RPC surface, Swift models, and UI components.

The work stacked two significant technical layers:
1. **DB**: Unified `kudo_json(uuid)` DRY builder feeding both `list_kudos` and new `view_kudo` RPCs; added `has_reacted` (per-user via `auth.uid()` inside SECURITY DEFINER); `view_kudo` uses a CTE so the builder evaluates once.
2. **Swift**: Kudo model gained `hasReacted` bool; KudoService adds `viewKudo()`, `react()`, `unreact()`; optimistic toggles in both KudosBoardViewModel and ViewKudoViewModel with rollback guards; wired tappable hearts on board cards and detail screen.

## The Brutal Truth

This felt clean on the surface but **three craft failures emerged during verification and review**, and a systemic security gap festered longer than it should have.

The optimistic UI was elegant right up until a reviewer caught a **rapid double-tap race condition** — both toggleReaction implementations were reading the same `wasReacted` state before the first Task mutated it, producing silent toggle loops. The All-Kudos cards also went live with the heart callback **not threaded through the parent**, so they were tappable but silent. Both are now fixed, but they shipped past first manual testing because optimistic patterns aren't naturally caught by visual inspection alone.

## Technical Details

**Fixture ID validation gap:** The summary doc referenced k1 as an all-1s UUID (11111111-...), but the actual seed generated 11111111-0000-...-0001. Testing against the wrong ID produced confusing 409 (Conflict) and null query results until `psql` revealed the true IDs. Lesson etched in blood: **never assume fixture IDs from memory; always verify against the live DB schema.**

**Simulator env vars:** Used `simctl launch BID KEY=VAL` expecting KEY=VAL to propagate as env vars; it doesn't. Env vars need `SIMCTL_CHILD_` prefix or they're treated as argv. This silently landed test screenshots on the wrong tab, making validation look broken when it was just routed wrong.

**Security oversight:** Supabase default privileges auto-grant EXECUTE on new functions to `anon` and `authenticated` roles. Revoking from `PUBLIC` alone left the internal `kudo_json` helper callable directly over /rpc at HTTP status 200. Reviewer flagged it; had to add explicit `REVOKE ... FROM anon, authenticated`. **This is a systemic gap** — the same pattern was flagged in migration-700 earlier and is still open as pre-prod hardening work. It's a time bomb waiting for the next function.

## What We Tried

- **Initial optimistic toggle:** Simple `@State var isReacted: Bool = kudo.hasReacted` in the ViewModel, toggled immediately on tap. ✗ Broke on rapid taps because the toggle happened in UI state before the server responded.
- **Guarded toggle v1:** Added a `wasReacted` local var to track the pre-request state. ✗ Still susceptible to double-tap if the second tap fired before the first Task started.
- **Guarded toggle v2:** Added an in-flight flag to prevent concurrent requests (the fix now in place). ✓ Works; rollback on error restores the correct state.

## Root Cause Analysis

**Why optimistic races happened:** The UI state (isReacted) is not the same as the request state (isInFlight). We read isReacted at tap time, but if two taps fire in the same frame before the first task mutates isInFlight, both read the same stale state. The fix is simple — guard the request, not the state — but it's not obvious until a reviewer or user hammers the button.

**Why security checks slipped:** New RPC functions inherit default Supabase permissions automatically. The pattern is: write the function, test it works, ship it. Nobody explicitly thinks "what if someone calls this over HTTP?" until a security audit kicks in. We need a pre-commit checklist for new functions: "Is this internal-only? If yes, REVOKE from roles explicitly."

**Why fixture IDs were wrong:** I built the seed based on the summary doc's assumption without verifying. The summary was written after an earlier migration that changed the seed logic, so it became stale. Single source of truth failed.

## Lessons Learned

1. **Verify fixture IDs in code, not in your head.** Before integration testing, run `psql` and confirm the UUIDs that landed in the DB. Automate this: a fixture-id validation step in the test harness.

2. **Optimistic UI requires in-flight state, not just UI state.** Use a guard like `isInFlight` to prevent concurrent requests. The pattern is trivial but easy to skip if you're thinking in UI terms instead of request state.

3. **Every new RPC function is a public endpoint until proven otherwise.** At function-write time, assume it will be called over HTTP by mistake. Add a comment or a pre-commit hook to remind: "New functions: did you REVOKE default permissions?"

4. **Double-tap prevention belongs in the ViewModel, not the View.** Views should not know about double-tap logic; they should receive a callback that's already guarded. This was backwards earlier; now fixed.

5. **Simulator env vars need the SIMCTL_CHILD_ prefix.** Document this in the testing guide because it's a gotcha that costs an hour.

## Next Steps

1. **Systematic security: Add RPC permission audit** to pre-prod checklist. Scan all functions in `schema_name.routines` and confirm they don't have PUBLIC EXECUTE. This is a one-time scan + a pre-commit step for new functions.

2. **Fixture validation in test harness:** Add a shell function that queries the seed UUIDs and exports them to the test summary. No more guessing.

3. **Update development guide:** Document the `SIMCTL_CHILD_` prefix for sim env vars and add the double-tap guard pattern as a "common optimistic UI gotcha" section.

4. **Backlog:** Mark migration-700 security cleanup (close the same RPC permission gap on earlier functions) as a blocker for prod deployment.

---

**Status**: Resolved with craft improvements noted
**Summary**: Kudo react/view shipped with optimistic UI and DB DRY layer. Security gap (RPC permissions) and double-tap race caught and fixed in review; fixture ID mismatch and simulator env var gotcha documented.
**Concerns**: Systemic RPC permission issue predates this batch and remains open across all functions — needs pre-prod audit and policy.
