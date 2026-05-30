# iOS Track B Backbone: Foundation, Models, Services, ViewModels

**Date**: 2026-05-30 14:05
**Severity**: Medium
**Component**: iOS architecture, state management
**Status**: Resolved

## What Happened

Forged the entire Track B backbone for 32 remaining iOS screens (Login+Home already complete). Built phases 01–04 of a 20-phase 2-track plan in `plans/260530-0022-ios-screens-implementation/`:

- **Phase 01**: Extended AppRouter (AppRoute, AppErrorKind, NavDestination enums + push/pop/path), MainTabView shell with placeholder tab roots, TopNavigationBar, app route switch
- **Phase 02**: Modeled 10 domain entities (User, Department, Hashtag, AwardType, Award, Kudo, KudoComment, AppNotification, SecretBox/Gift, ContentSection/CommunityStandard/Rule)
- **Phase 03**: Built 6 services as @MainActor singletons (User, Kudo, Award, Notification, SecretBox, Content) — stubbed Supabase calls, typed LocalizedError enums
- **Phase 04**: Implemented 10 @Observable @MainActor ViewModels with validation, state machines (SendKudo, SecretBox), debounced search, double-click guards

**Verification**: BUILD SUCCEEDED on iPhone 17 / iOS 26.2 simulator. Xcode auto-synchronized new files (PBXFileSystemSynchronizedRootGroup).

## The Brutal Truth

This was the necessary unglamorous work — no visible pixels yet, but everything downstream depends on it being **correct**. The review caught a critical domain invariant violation that could have become a time-bomb in the UI layer. That's why we didn't just stub-and-move-on.

## Technical Details

**Critical Bug Found & Fixed**: Kudo.sender was a public property, allowing views to bypass anonymity rules. Made it private, added custom `init(from:)` that nils sender when `isAnonymous=true`, exposed safe `resolvedSender` accessor. ViewKudoViewModel now uses it.

**Race Conditions Patched**:
- AllKudosViewModel.load() reset-vs-inflight on loadMore
- KudosBoardViewModel.apply(filter:) missing in-flight guard

**iOS 26.2 Deployment Target**: Xcode default destination didn't match; had to explicitly select iPhone 17 / iOS 26.2 simulator or build failed with "no matching destination" error.

## What We Tried

Single approach: build a complete, verified backbone before spawning 14 UI agents. Avoided parallelizing UI too early (resource limits, simulator contention). Reviewed with `reviewer` agent immediately post-build.

## Root Cause Analysis

The anonymity bug existed because model fields were public. Classic layering mistake: treating models as dumb containers instead of domain entities that enforce their own invariants. iOS's swift access control made this easy to get wrong.

The iOS deployment target issue was user error (not specifying simulator version) hitting Xcode's destination resolution defaults.

## Lessons Learned

1. **Enforce invariants at the model boundary.** Privacy, validation, state machines belong in the entity itself, not sprinkled across ViewModels and Views. Future self won't remember why sender must be nilled; the model should make it impossible.

2. **iOS deployment target must match simulator.** Don't trust Xcode's default destination. Explicit iPhone 17 / iOS 26.2 selection prevents build surprises later.

3. **PBXFileSystemSynchronizedRootGroup is a gift.** No manual pbxproj edits needed when adding files to Xcode groups — let the filesystem be the source of truth.

4. **Review immediately after building new layers.** Domain models + services are easy to rush; catching invariant violations here prevents cascading bugs in 14 UI screens later.

## Next Steps

1. Batch UI implementation in clusters (5–6 screens per batch) to avoid simulator saturation
2. Wire up Track A outputs to Track B services as UI agents complete
3. Integration phase (phase 19) once all screens delivered

**Owner**: Continue with Track A agents (maintainer handles coordination)
**Timeline**: Phase 05–18 (14 screens) in 3 parallel clusters, phase 19 integration after

---

**Status**: DONE
**Path**: `/Users/nguyen.vuong.thanh.loc/Desktop/LearnApp/Mock/MockProjectAIDD/docs/journals/2026-05-30-ios-backbone-track-b.md`
