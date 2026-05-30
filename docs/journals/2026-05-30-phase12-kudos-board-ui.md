# Phase 12: Sun* Kudos Board UI Implementation

**Date**: 2026-05-30 14:44
**Severity**: Low
**Component**: Track A / KudosBoardView (presentational layer)
**Status**: DONE

## What Happened

Built the first Track A UI screen for plan 260530-0022: the Kudos Board view. Delegated to one `implementer` subagent running `momorph-implement-design` skill against Figma screen fO0Kt19sZZ (2 dropdown interaction states). Created KudoCard and KudosBoardView components with full keyboard/accessibility support, plus a reusable generic FilterOverlay for hashtag/department filtering. Code review cycle caught and fixed 3 high-priority issues. Build succeeds with zero warnings on iOS 26.2.

## The Brutal Truth

The file-size rule (<200 lines) is easier to break than expected on rich SwiftUI screens. We nearly shipped a 280-line KudosBoardView before splitting it. SwiftUI's declarative nesting makes it tempting to stuff everything into one view — have to be disciplined about splitting header/content/section concerns upfront. Also, creating two separate overlay components for hashtag and department filtering was wasteful before the reviewer pointed out the generic pattern. Small waste, but it compounds.

## Technical Details

**Files Created:**
- `Views/KudosBoard/KudosBoardView.swift` (140 lines)
- `Views/KudosBoard/KudoCard.swift` (95 lines)
- `Views/KudosBoard/KudoCardHeader.swift` (65 lines)
- `Views/KudosBoard/KudoCardContent.swift` (75 lines)
- `Views/KudosBoard/KudosHighlightSection.swift` (55 lines)
- `Views/KudosBoard/KudosAllSection.swift` (60 lines)
- `Views/KudosBoard/KudosSharedComponents.swift` (50 lines)
- `Views/Common/FilterOverlay.swift` (88 lines, generic `<Item: Identifiable>`)
- `Extensions/Color+KudosTokens.swift` (42 lines)

**Public Contract:**
```swift
KudosBoardView(
  kudos: [Kudo],
  hashtags: [Hashtag],
  departments: [Department],
  onSelectHashtag: (Hashtag?) -> Void,
  onSelectDepartment: (Department?) -> Void,
  onOpenKudo: (Kudo) -> Void,
  onSendKudo: (Kudo) -> Void
)

KudoCard(
  kudo: Kudo,
  onCopyLink: (() -> Void)?,
  onViewDetail: (() -> Void)?
)
```

**Review Findings (Fixed):**
- **H1 (File Size)**: KudosBoardView was 280 lines → split into KudosHighlightSection + KudosAllSection + shared subcomponents (now all <150 lines).
- **H2 (Performance)**: DateFormatter instantiated per render → moved to `static let` in extension.
- **H3 (UX Bug)**: onSendKudo callback undefined → wired from parent ViewModel.

**Anonymity Audit**: resolvedSender computed property confirmed safe; no direct access to `.sender` in views. Meets privacy requirements.

## What We Tried

1. Initially built separate HashtagFilterOverlay and DepartmentFilterOverlay components.
2. Reviewer flagged redundancy → replaced both with generic `FilterOverlay<Item: Identifiable>(items, labelKeyPath, selection, onSelect)`.
3. Used inline DateFormatter in KudoCardHeader → caught by profiler simulation, moved to static.
4. KudosBoardView reached 280 lines with all sections inline → split into dedicated subviews.

## Root Cause Analysis

**Why file-size blew up:** SwiftUI's chaining syntax hides complexity — a single `VStack` with nested views and modifiers reads cleanly but compounds line count fast. The view wasn't overfit for one screen; it was just poorly chunked. Should have sketched the component tree before writing code.

**Why two overlay clones existed:** Built hashtag filter first, copy-pasted for department. Only caught during review because we weren't thinking "generic overlay" upfront — assumed each would be special. It wasn't.

## Lessons Learned

1. **Sketch component tree before code**: For a screen with 3+ sections or interactive elements, spend 2 minutes listing subview names. Prevents last-minute file-size refactors.
2. **Generic containers first**: FilterOverlay<Item> pattern (labelKeyPath, Identifiable binding) is now the playbook for remaining pickers in phase 14 (send-kudo recipient, hashtag, department). Use it instead of duplicating.
3. **Static DateFormatters pay off**: iOS formatters are expensive on re-renders. One-time static allocation in extensions saves frame drops on scrolling.
4. **Review loop efficiency**: Keeping the same implementer agent for code review (instead of handing off) preserved full context and made fix iterations snappy.

## Next Steps

- **Deferred (Spotlight Board)**: Figma node mms_B.7_Spotlight (mosaic/ticker section) flagged as complex animated component with no spec data. Defer to dedicated animation pass.
- **Avatar badges**: Simplification to text pending badge model work in phase 19.
- **Remaining Track A**: Phases 05–11, 13–18 (13 screens total), plus phase 19 integration.
- **Backend integration ready**: KudosBoardView accepts kudos array + callbacks. Backend fetch logic wires in during phase 13 (KudosViewModel integration).

**Unresolved Q**: Spotlight mosaic animation scope — is it a scroll ticker or a static mosaic? Needs clarification in phase 19.

---

**Status**: DONE
**Output**: `/Users/nguyen.vuong.thanh.loc/Desktop/LearnApp/Mock/MockProjectAIDD/docs/journals/2026-05-30-phase12-kudos-board-ui.md`
