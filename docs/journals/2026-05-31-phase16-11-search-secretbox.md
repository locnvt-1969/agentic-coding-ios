# Phase 16–11: Search Sunner + Secret Box Parallel Sprint

**Date**: 2026-05-31 11:00
**Severity**: Medium
**Component**: SearchSunnerView, SecretBoxView (Track A — presentational screens)
**Status**: DONE

## What Happened

Executed phases 16 (Search Sunner idle/searching/results UI) and 11 (Secret Box closed→opening→standby states + animations) in parallel for the first time post-incident. User explicitly opted in, citing full file disjunction between the two screens.

## The Brutal Truth

After the git-stash-during-parallel disaster last month, I was wary. But this run proved the root cause was agent misconduct with git, **not parallelism itself**. Two independent agents, zero git, isolated derived data paths, zero overlap. Built clean. This should have been the baseline all along.

## Technical Details

**Phase 16 (SearchSunnerView):**
- Views: SearchSunnerView, SearchSunnerSubviews, SunnerResultRow
- State: idle/searching/results driven by VM
- All <200 lines; Build SUCCEEDED iOS 26.2 zero warnings

**Phase 11 (SecretBoxView):**
- Views: SecretBoxView, SecretBoxClosedView, SecretBoxOpeningView, SecretBoxStandbyView
- Color+SecretBoxTokens extension
- 5 PNG assets (closed, opening loop frames, standby)
- All <200 lines; Build SUCCEEDED iOS 26.2 zero warnings

**Build artifact (transient):** During parallel execution, SearchSunner agent saw BUILD FAILED briefly — SecretBox agent was still writing PNGs. Once orchestrator ran full build, SUCCEEDED. Lesson: mid-run per-agent status is noise; trust the final unified build.

## What We Tried

**Guardrails applied:**
1. Emphatic git ban in both agent prompts (no stash, no branch ops)
2. Isolated `-derivedDataPath dd-p16` and `dd-p11` per agent (prevents Xcode contention)
3. Strict disjoint file ownership: `Views/Kudos/SearchSunner*` vs `Views/SecretBox/*`
4. No shared-file edits across agents

Result: Clean parallel run, zero git incidents, zero file conflicts.

## Root Cause Analysis

**Prior Disaster (April):** Agent ran `git stash` mid-implementation, corrupting shared files. Parallelism was blamed; git abuse was the culprit.

**This Run:** Banned git entirely + isolated build artifacts + file disjunction = safety. Confirms parallelism is viable for truly independent screens when guardrails are enforced.

## Lessons Learned

1. **SwiftUI .transition() is dead without an animation drive site** — paired every transition with `.animation(value:)`. Without it, closed→opening→standby declared but never animated (fix directly fulfilled animation requirement).

2. **Hardcoded frame widths from Figma are a recurring trap** — Reviewer caught nav-bar `375pt` width and search background `881pt` → replaced with `.maxWidth(.infinity)` and flexible fill. Always flag fixed pixel dimensions in review.

3. **Presentational views must not bake preview data** — SearchSunner had hardcoded `recentUsers` in struct body. Promoted to defaulted `@State` prop, now wired `onRemoveRecent` callback.

4. **Parallel is safe for disjoint work with strong guardrails** — git ban + isolated build paths + file ownership clarity = zero incident. Lesson for future parallel sprints.

## Next Steps

- **Deferred (phase-19 integration):** Search back icon (SF Symbol vs Figma SVG); SecretBoxView.boxCount real VM source; project-wide `navigationBarHidden` deprecation cleanup
- **Track A progress:** 09/14 screens done (08,09,10,11,12,13,14,15,16). Remaining: 05,06,07,17,18 + phase-19 cross-screen wiring

---

**Status**: DONE

**File path**: `/Users/nguyen.vuong.thanh.loc/Desktop/LearnApp/Mock/MockProjectAIDD/docs/journals/2026-05-31-phase16-11-search-secretbox.md`

