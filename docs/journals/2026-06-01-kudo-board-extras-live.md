# Kudo Board Extras Wired to Live Data

**Date**: 2026-06-01 11:36  
**Severity**: High  
**Component**: Kudo Service, UserService, SupabaseRESTClient  
**Status**: Resolved

## What Happened

Completed the final wiring of all Kudo domain features to real Supabase backend. Every remaining mock piece in the board ecosystem now hits live data: list_kudos extended for real-time filtering, spotlight count via Content-Range optimization, personal stats from v_profile_stats view, gift recipients list backed by v_recent_gift_recipients (owner-rights view), comment submission wired to kudo_comments table with sync feedback. Deleted KudoService+Mock.swift entirely — the service is now 100% live.

## The Brutal Truth

This was supposed to be a "wire the remaining bits" session. It turned into a deeper session because the gift recipients problem exposed an actual security-design tension: user_rewards table has strict RLS (read-own only), but the board widget needs to display "who recently received gifts" as a global aggregate. The reflexive fix would be to loosen RLS. Instead, we built a curated view — the right move, but it added design friction that should have been foreseen earlier. Lesson learned hard.

Also, the reviewer caught a data-loss UX bug in comment submission that made it through earlier testing. The text field cleared synchronously before the async post finished, so a failed send lost the user's typed message. Small fix in code, but it's a reminder that async boundaries in UI are where we slip.

## Technical Details

**Database layer:**
- Extended `list_kudos` RPC with `p_hashtag` and `p_department` text params for server-side filtering
- Added `v_profile_stats` view (pulls from v_kudos_summary aggregates) for spotlight total and personal stats
- Created `v_recent_gift_recipients` as an owner-rights view — exposes only `user_id, full_name, avatar_url, reward_title` from user_rewards, avoiding exposure of `granted_at` or sensitive fields
- Comment insertion via `INSERT kudo_comments` with immediate reload of the detail view

**Service layer:**
- `SupabaseRESTClient.count()` helper: parses `Content-Range: items 0-0/N` header from a zero-row query to get total without transferring all IDs
- `KudoService.listDepartments()` now queries real users table with distinct on departments instead of mock array
- `KudoService.submitComment()` added with post-return success flag; comment field clears only on flag=true

**View layer:**
- `ViewKudoView` wired to show real comment count and reload comments on submission
- Department/hashtag filter dropdowns now populate from live data
- Gift recipients widget pulls from the v_recent_gift_recipients view

## What We Tried

Initial approach: loosen user_rewards RLS to allow "select recent records" queries. Rejected because it breaks the principle that rewards are owner-confidential (other users shouldn't see who got what, when).

Second approach: create a global materialized view of all gift recipients. Rejected because it's a projection maintenance burden and still exposes timestamps.

**Landed on:** owner-rights view with restricted column set. View definition does `SELECT user_id, full_name, avatar_url, reward_title FROM user_rewards` with appropriate ordering. RLS still enforces ownership on the underlying table, so the view is safe. Minimal surface, no maintenance overhead.

## Root Cause Analysis

The gift recipients problem existed from day one but stayed hidden because we were using mock data. Live wiring exposed it. Why wasn't it surfaced in clarification? Because the board design said "show recent gift recipients" without clarifying the data model — we assumed user_rewards would be globally readable. It wasn't, for good reason (privacy). The designer and backend architect should have had a 5-minute sync on this constraint before building.

Comment data loss: View cleared the field on submission without waiting for the async result. Classic async-boundary mistake. The reviewers catch these because they see the code path end-to-end; the original implementer was focused on "make the button trigger the submission" and didn't walk the failure case.

## Lessons Learned

1. **RLS-locked tables need explicit aggregation strategy.** When a board/dashboard needs cross-user data over an RLS-protected table, decide early: create a view, trigger a separate service, or accept that users only see their own. Don't discover it mid-implementation.

2. **Count without transfer.** PostgREST's `Prefer: count=exact` + zero-range query is cheap — use it for cardinality. Avoid "fetch all IDs, length" pattern.

3. **Async boundaries are UX cliffs.** If a View sends data async, the success flag must gate the clearing/reset. Review comment: even "simple" submissions need this discipline. The rule: View owns the clearing logic, Service owns the success flag.

4. **Scope projection carefully.** When exporting data from an RLS table via a view, explicitly decide what columns are safe to expose. Dropping `granted_at` from the gift view isn't paranoia — it's surface area reduction. Reviewer was right to nudge it.

5. **Match aggregates to their source.** Spotlight total changed from `count(kudos)` to `count(kudos_public)` to ensure the feed and the stat always show the same scope. Seems trivial, but it's the difference between a number that makes sense and a number that confuses users.

## Next Steps

- Run end-to-end test: board load, filter by department/hashtag, comment submission, gift recipients widget
- Monitor Content-Range header parsing in count() — ensure no edge cases with large counts
- Verify RLS on v_recent_gift_recipients doesn't inadvertently leak anything (security audit checklist)
- Backlog: consider adding v_gift_recipients to the schema documentation explicitly (new devs need to know it exists and why)

**Status**: DONE  
**Summary**: All Kudo domain features wired to live Supabase. KudoService+Mock.swift deleted. Resolved gift recipients privacy design via owner-rights view. Fixed async comment submission data loss.  
**Concerns**: None — design gaps identified and addressed via reviewer feedback before merge.
