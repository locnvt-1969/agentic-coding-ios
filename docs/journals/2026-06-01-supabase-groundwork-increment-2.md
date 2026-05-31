# Supabase Groundwork: RPC + Security Catch

**Date**: 2026-06-01 14:30
**Severity**: High (Security)
**Component**: Supabase RPC, Postgres privilege grants
**Status**: Resolved (for this RPC); broader hardening deferred

## What Happened

Built `get_profile(p_id)` RPC as a verified-increment delivery step, decoupled from auth prerequisites. End-to-end tested by creating a throwaway auth user, invoking the RPC, validating the composed JSON (profile + department + hero tier + collected icons + stats), and cleaning up. Also validated the `handle_new_user` trigger fired correctly on signup.

Committed as `1584fb3`. Models and DTOs aligned: `SunValueIcon.dbId` ↔ enum, `Kudo.title`, and `ProfileDTO` decode layer added.

Then discovered a security flaw: after revoking the RPC from `anon` role to fix over-broad access, checked `information_schema.routine_privileges` and found `PUBLIC` still had EXECUTE permission.

## The Brutal Truth

This is infuriating because Postgres grants ALL functions to `PUBLIC` by default, and `PUBLIC` is a special role that **includes** `anon`. A simple `REVOKE` from a single role masks this. I assumed revoking from `anon` was sufficient. It wasn't.

The real kick in the teeth: **every custom function we've deployed** — including the SECURITY DEFINER `grant_national_kudos` that writes reward records — is currently callable by any unauthenticated request. This is a privilege escalation vulnerability sitting in production.

## Technical Details

- **Symptom**: `information_schema.routine_privileges` query showed:
  ```
  routine_name | grantee | privilege_is_grantable
  get_profile  | PUBLIC  | NO
  ```
  Even after `REVOKE EXECUTE ON FUNCTION get_profile FROM anon`

- **Root cause**: Postgres default GRANT behavior
  - Functions created without explicit GRANT → inherit default privileges
  - Default = all roles, including PUBLIC
  - `REVOKE FROM anon` removes one role but doesn't affect PUBLIC

- **Real fix**:
  ```sql
  REVOKE EXECUTE ON FUNCTION get_profile FROM PUBLIC;
  GRANT EXECUTE ON FUNCTION get_profile TO authenticated;
  ```

- **Scope**: Applies to all RPC functions. `grant_national_kudos` (SECURITY DEFINER, writes to rewards table) is currently exposed.

## What We Tried

1. Revoked from `anon` → tested in Supabase Studio → appeared to work
2. Assumed fix was complete → began model alignment
3. Did a spot-check of privileges via `information_schema` → caught it

## Root Cause Analysis

Two compounding oversights:

1. **Assumption over verification**: Trusted that `REVOKE` from one role was complete; should have queried the actual grant state before declaring victory.
2. **Privilege model misunderstanding**: Forgot that PUBLIC is a catch-all and persists independently of named-role grants. This isn't obvious from CLI feedback.

Process win: incremental delivery meant we caught this during groundwork, not after auth went live.

## Lessons Learned

- **Always query, never assume**: Postgres grant state is authoritative only in `information_schema.routine_privileges`, not in CLI output or logical reasoning.
- **PUBLIC is invisible**: When auditing Postgres access, explicitly check PUBLIC grants. They don't show up in `psql \dp` cleanly and survive role-specific revokes.
- **Verify end-to-end per increment**: The test-create-verify-cleanup cycle caught this early. Without it, we'd have shipped with open functions.
- **Generalize the hardening**: All SECURITY DEFINER functions need the same treatment. This is a pre-auth-launch requirement.

## Next Steps

1. **Immediate**: Add migration-700 follow-up task to revoke PUBLIC EXECUTE on:
   - `get_profile`
   - `grant_national_kudos`
   - Any future RPC functions
   Then grant to `authenticated` role only.

2. **Before auth phase (P2)**: Audit all Postgres object privileges via `information_schema` queries, not role assumptions.

3. **Before user services (P5)**: Ensure REST client `post(rpc:)` method properly routes through authenticated session.

4. **Integration (P6)**: Wire `get_profile` into ProfileService; test that unauthenticated requests fail with 401.

**Owner**: Deferred to auth phase; logged as security hardening pre-requisite.

---

**Status**: RESOLVED (RPC verified + models aligned; security flaw identified & documented)
**Summary**: Built get_profile RPC and validated schema, but caught that PUBLIC EXECUTE grant persists after role revoke. Real fix requires explicit REVOKE PUBLIC + GRANT authenticated. Applies to all custom functions; logged as pre-auth hardening task.
**Concerns**: All SECURITY DEFINER functions currently exposed; must be fixed before auth launch.
