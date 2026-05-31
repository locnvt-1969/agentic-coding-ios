# Increment 1: From Mock Data to Live Supabase Reads

**Date**: 2026-06-01 04:56  
**Severity**: N/A — Milestone  
**Component**: Content delivery (Community Standards, Rules), REST client, database integration  
**Status**: COMPLETE

## What Happened

Executed Increment 1 of the Supabase API integration plan (phase-01-foundation). Built a reusable `SupabaseRESTClient` actor and wired `ContentService` to read the live database, proving end-to-end that the app can fetch public content from Postgres via PostgREST. Verified by tagging a database row with a `[FROM DB]` marker and watching it render in the app. The foundation is in place for OAuth, user data writes, and real Kudos later.

## The Brutal Truth

We chose to accept mock data in several UI layers (Profile screens, Secret Box counts, Kudo stats) rather than rebuild them. Profile screens were already implemented but empty; instead of gutting them, we populated with mock data and refined the UI (added SunValueIcon display, styled the Spam tag). This felt like a pragmatic shortcut until halfway through the session I realized: **the gap was never the UI logic—it was just the mock data being absent.** We should have verified this early and treated it as a data problem, not a UI problem.

The real surprise was a scroll-bug rabbit hole on Community Standards. After three identical-looking screenshots, I added a marker screen to prove the build pipeline worked. That single diagnostic marker saved an hour of thrashing through SafeArea APIs. The root cause was trivial: `ignoresSafeArea(.top) + navigationBarHidden` inside a NavigationStack forcing a negative scroll offset. Swapped it for `.safeAreaInset(edge:.top)` + `.toolbar(.hidden)` and it disappeared. But the lesson is raw: sometimes the answer isn't in the code; it's in proving the build is actually reflecting your changes.

## Technical Details

**SupabaseRESTClient (actor)**: 88 lines, generalizes the AwardsService pattern. Handles:
- GET requests to PostgREST with URLQueryItems (filter, order, select)
- JSON decoding with snake_case → camelCase key mapping
- Bearer auth (anon key fallback, JWT token when auth lands)
- Error handling (invalidURL, network, serverStatus, decoding) with Vietnamese localization

**ContentService**: Reads `content_sections` table filtered by `document_id` ('community_standards' or 'rules'), returns ordered sections. No caching; simple request-per-call. Throws ContentError on failure.

**Database**: 8 migrations + 7 seeds (verified via `supabase db reset` 0 errors). Schema covers:
- 1 identity layer (profiles, departments)
- 2 awards (extends existing; adds award_criteria, award_recipients)
- 6 kudos (kudo + hashtags + reactions + comments + stats views)
- 7 gamification (value_icons, secret_boxes, rewards, hero_tiers, user_value_icons, national_kudos view, user_rewards)
- 4 content (content_documents, content_sections — the foundation for CMS-style delivery)
- 8 notifications (notifications table + RLS + filtering by kind)
- RLS policies on all user-scoped tables; public SELECT on reference tables

**Proof**: Manually inserted a test row into `content_sections` with `id = 'test-marker'` and text `'[FROM DB]'`, queried it in the app, saw the marker render. Deleted the row, marker vanished. Not a screenshot hallucination; real database I/O.

## What We Tried

1. **Rebuild Profile screens from Figma** → Too aggressive; the layout was already correct, just needed mock data. Deferred.
2. **Fix scroll bug by tweaking ScrollView props** → Changed offset hints, rotation effects, frame modifiers. Nothing stuck.
3. **Add marker view to prove build caching** → Build clean, redeployed, marker appeared in exactly the right place. Proved the pipeline worked; isolated the bug to the view logic.
4. **Diagnose safe-area APIs** → Empirically tested: `ignoresSafeArea(.top)` + `NavigationStack` = forced negative offset. `.safeAreaInset(edge:.top)` = pinned bar, natural scroll. Applied to RulesView and CommunityStandardsView; scroll fixed.

## Root Cause Analysis

**Why mock data lingered in Profiles**: Profile views were born during UI phases 05-18 (Track A), when services were stubs and the focus was "does the layout match Figma?" Once integrated (phase 19), profile data still came from hardcoded arrays. I assumed a ViewModel gap, but checking the code revealed: ViewModels existed and had fetch logic; they just never ran because the Container never called `load()` or the async task was missing.

**Why the scroll bug persisted**: NavigationStack inside SwiftUI has a quirk: if a view claims `ignoresSafeArea(.top)`, the scroll offset is automatically adjusted downward to avoid occluding the nav bar. But since we also applied `navigationBarHidden`, the system still applied the offset—leaving a gap. The old pattern (`.ignoresSafeArea(.top) + navigationBarHidden`) worked pre-iOS 16 when navigation was UIKit-driven. Lesson: **check the iOS version in your rules.** We're on 26.2+, which means NavigationStack native behavior.

**Why we didn't catch this earlier**: Parallel Track A (UI phases) didn't cross-check with nav patterns until integration. The CommunityStandardsView and RulesView were created by different people, in different phases. One used `.safeAreaInset` (correct), one used `ignoresSafeArea(.top)` (cargo cult). When both landed in the app, we ran 3 revisions of screenshots before the inconsistency surfaced in testing.

## Lessons Learned

1. **Verify before rebuilding**: Ask "Is the gap architecture or data?" Profile screens proved the answer was data. A 5-minute inspection beats a 2-hour refactor.

2. **Marker debugging is underrated**: When you're staring at three identical screenshots and can't trust your eyes, add a rendered marker (text, color flash, debug border) tied directly to the data or logic. If the marker appears, the code is running. If it doesn't, the build is stale or the view isn't mounted.

3. **Document your navigation patterns in code standards**: We had two subtly different safe-area approaches in the same codebase. A rule like "Always use `.safeAreaInset(edge:.top)` for pinned bars inside NavigationStack; never use `.ignoresSafeArea(.top) + navigationBarHidden`" in `code-standards.md` would have caught this at PR review.

4. **Actor clients are flexible**: The `SupabaseRESTClient` generalizes well. Adding POST/PATCH/DELETE later will be one method each. The snake_case decoder setup once, reuse forever.

5. **Public reads don't need auth yet**: Both ContentService calls use the anon key (via `SupabaseRESTClient` fallback). No JWT complexity. Next increment (OAuth + user services) will set `accessToken` on the client, and all reads automatically upgrade. Clean separation.

## Next Steps

- **Increment 2 (phase-02-auth)**: Wire AuthService to Supabase.GoTrueClient (or stub again if SDK unavailable). Google OAuth redirect handling, session refresh, logout.
- **Increment 3 (phase-03-models-dto)**: Define Codable DTOs for Kudo, User, SecretBox (match the schema, not the old mock models).
- **Increment 4 (phase-04-read-services)**: UserService (fetch profile, kudos sent/received, hero tier, value icons), KudoService (fetch board, single kudo, reactions).
- **Increment 5 (phase-05-user-services)**: Write paths — SendKudoService, ReactService, OpenSecretBoxService (trigger `open_secret_box()` RPC).
- **Integration (phase-06)**: Replace all mock data with service calls, test end-to-end (login → write kudo → react → view secret box).
- **Docs**: Update system-architecture.md and code-standards.md with REST client pattern and safe-area guidance.

---

**Status**: DONE  
**Summary**: Built REST foundation, proved live database reads, identified and fixed scroll-bug anti-pattern, deferred non-critical mock data refreshes. Ready for OAuth increment.  
**Concerns**: None blocking. Safe-area pattern inconsistency should be documented to prevent future cargo-cult edits.

Co-Authored-By: Claude Opus 4.8 (1M context) <noreply@anthropic.com>
