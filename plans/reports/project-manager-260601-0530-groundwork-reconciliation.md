# Reconciliation Report — Increment 2 Groundwork Batch (2026-06-01)

**Project:** MockProjectAIDD · **Phase:** Supabase API integration (Increment 2) · **Batch:** Auth-independent groundwork

---

## Summary

Groundwork batch for Increment 2 completed and reconciled. Build SUCCEEDED, 0-critical review findings. Foundation laid for P5 user-context services: `get_profile` RPC deployed, model/DTO layer aligned. All deliverables recorded; follow-up blockers logged explicitly for later phases.

---

## Completed Work

| Item | Status | Evidence |
|------|--------|----------|
| P1: `get_profile(p_id)` RPC | **DONE** | Migration `20260601000800_get_profile_rpc.sql` applied; SECURITY DEFINER grant to `authenticated` only; end-to-end verified |
| P3: `SunValueIcon.dbId` mapping | **DONE** | `dbId` property + `init?(dbId:)` implemented; all 6 cases round-trip |
| P3: `Kudo.title` field | **DONE** | Added `String?` optional title; anonymity invariant enforced in decoder |
| P3: `ProfileDTO` decode layer | **DONE** | Maps `get_profile` JSON → `User` + `ProfileStatsData`; `.convertFromSnakeCase` via REST client |
| Build | **PASSED** | `xcodebuild build` SUCCEEDED |
| Code Review | **PASSED** | 0 critical findings (2 fixes applied from prior cycle) |
| Integration test | **VERIFIED** | RPC JSON structure validated; model mapping tested |

---

## Plan Status Updates

**plan.md (Increment 2 baseline table):**
- P1 Foundation: now `PARTIAL` (RPC done; SDK client deferred)
- P3 Models/DTO: now `PARTIAL` (SunValueIcon/Kudo/ProfileDTO done; KudoDTO pending)
- Phase/deliverable sections updated with groundwork specifics

---

## Blocked Follow-ups (Logged, Not Addressed)

These unblock P5 and P2 hardening but are out of scope for this groundwork batch:

1. **P5 gate (SupabaseRESTClient):** POST method needed for RPC call wiring
   - Current: `get()` only
   - Required: `post(rpc: String) async throws → T`
   - Owner: P5 implementer

2. **P5 service layer:** null-safety for RPC unknown id
   - `get_profile(unknown_uuid)` → null JSON
   - Map to: `UserError.notFound` in `UserService.getProfile()`
   - Owner: P5 implementer

3. **SECURITY hardening (P2 phase):** revoke PUBLIC EXECUTE on sensitive functions
   - `grant_national_kudos` (writes `user_rewards`) currently PUBLIC-callable
   - Fix location: migration `20260601000700`
   - Action: `revoke execute on function public.grant_national_kudos(...) from public`
   - Owner: P2 implementer

---

## Files Modified

| File | Change |
|------|--------|
| `plans/260601-0418-supabase-api-integration/plan.md` | Status table: P1 PARTIAL + P3 PARTIAL; deliverables section updated; follow-ups logged |
| `docs/project-changelog.md` | Entry: "Supabase API groundwork: get_profile RPC + model/DTO alignment"; lists RPC + model updates + verified; notes blocked follow-ups |

## Files Not Changed (Per Instructions)

- `docs/system-architecture.md` — doc-writer owns
- `docs/code-standards.md` — doc-writer owns
- `docs/development-roadmap.md` — no genuine milestone change (Phase 7 still pending)

---

## Scope Adherence

✓ Auth-independent: no OAuth, no session, no user-context service wiring
✓ Build verified
✓ Review passed (0 critical)
✓ RPC end-to-end verified
✓ Model/DTO alignment for P5 readiness

---

## Next Actions (For Implementation Phases)

1. **P1 implementation:** Install Supabase Swift SDK (SPM); create `SupabaseClientProvider`; verify smoke read
2. **P2 implementation:** Google OAuth + session restore; security hardening (revoke PUBLIC from sensitive functions)
3. **P5 implementation:** Extend `SupabaseRESTClient` with `post(rpc:)` method; wire `get_profile` → `UserService.getProfile()`; handle null → `UserError.notFound`

---

**Date:** 2026-06-01  
**Reconciliation complete:** All groundwork documented, blockers logged, plan updated.
