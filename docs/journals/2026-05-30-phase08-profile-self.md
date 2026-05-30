# Phase 08: Profile bản thân (Self) — Subview Foundation Built

**Date**: 2026-05-30 15:51  
**Severity**: Low  
**Component**: iOS UI — Profile cluster, Track A step 1  
**Status**: Done

## What Happened

Implemented Phase 08 (Profile self-view) using momorph-implement-design on screen hSH7L8doXB. Built viewer-agnostic subview layer (ProfileHeader, ProfileBadges, ProfileStats) that will be reused immediately in Phase 09 (Profile của người khác).

## The Honest Assessment

This session ran *clean*. One implementer, sequential execution, no git collision. Confirms last session's lesson: single-agent runs on shared git trees avoid the parallel-merge nightmares. The real win was designing from the start with "viewer-agnostic" — no `isCurrentUser` flags in subviews, just pass the data and callbacks. Phase 09 is now nearly free.

## Technical Details

**Built:**
- `ProfileSelfView.swift` — container, edit overlay, bottom sheet for name/bio edit
- `ProfileHeader.swift` — user avatar, name, bio, follow/message buttons (passed params only, no "self" assumptions)
- `ProfileBadges.swift` + `ProfileBadgeSlot.swift` — badge grid; fallback SF Symbol "rosette" when award icons missing
- `ProfileStats.swift` — stats row (followers, following, kudos given/received)
- `ProfileKudosSection.swift` — reuses existing KudoCard component
- `Extensions/Color+ProfileTokens.swift` — profile color tokens
- Assets: `Assets.xcassets/Momorph/Profile/` (avatar placeholder, badge backgrounds)

**Code metrics:**
- All files ≤ 150 lines (well under 200)
- Build: **PASSED** iOS 26.2

**Sample data wiring:**
- Integrated ProfileSelfView into MainTabView Profile tab with mock User object
- Real stats/counts and persistence deferred to Phase 19

## What Went Right

1. **Viewer-agnostic design from the start** — ProfileHeader, ProfileBadges, ProfileStats accept data + callbacks only. Phase 09 reuses ~95% without modification.
2. **Graceful asset fallback** — Missing award icons don't render as blank spaces; they show SF Symbol "rosette" instead. Pattern for any deferred asset.
3. **Sequential single-agent execution** — Zero git conflicts, clean commit. Last session's rule held.
4. **Removed misleading API** — onEdit prop on ProfileHeader was passed but unused; removed to avoid confusion for Phase 09 implementer.

## What's Deferred (Not Bugs)

- Award badge icons: `<AwardFolder>_icon` assets (Phase 10 responsibility)
- Real stats/kudos counts: wired to Phase 19 data fetching
- Edit overlay mechanics: hardwired dismiss in Phase 08; full BottomSheet+Form lifecycle in Phase 09

## Reusability Inventory

For Phase 09 (Profile người khác):

| Component | Reuse Status | Notes |
|-----------|---|---|
| ProfileHeader(user:displayMode:onFollow:onMessage:) | Ready | Viewer-agnostic; no edit button |
| ProfileBadges(badges:) | Ready | Pure presentation |
| ProfileStats(stats:) | Ready | Pure presentation |
| ProfileLevelBadge | Ready | Shared |
| ProfileBadgeSlot | Ready | Fallback SF Symbol working |
| KudoCard | Already shared | — |

Phase 09 needs only: container, network fetch, permission check for "message" button.

## Lessons

1. **Defer edit/delete affordances to the viewer scope** — Don't pass isCurrentUser through component layers. Let the container decide what buttons appear.
2. **Asset fallback first, real asset second** — Build with graceful degradation from day one. Saves phase blockers later.
3. **Sequential single-agent rule holds** — No parallel agents on shared git tree. Confirms orchestration lesson from 2026-05-29.

## Next Steps

- Phase 09 (Profile người khác): start implementer agent; reuse ProfileHeader/ProfileStats/ProfileBadges stack (minimal new code)
- Phase 10 (Award badge icons): design <AwardFolder>_icon asset bundle
- Phase 19 (Real data): wire ProfileHeader, ProfileStats to UserService fetch; replace mock User

---

**Status**: DONE  
**File**: `/Users/nguyen.vuong.thanh.loc/Desktop/LearnApp/Mock/MockProjectAIDD/docs/journals/2026-05-30-phase08-profile-self.md`
