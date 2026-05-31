// AwardsLoadState.swift
// MockProjectAIDD
//
// Drives the Awards section UI (TC_IOS_HOME_GUI_002/003/004, TC_IOS_HOME_FUN_003).

import Foundation

enum AwardsLoadState: Equatable {
    case idle
    case loading
    case loaded([AwardItem])
    case empty
    case error(String)

    static func == (lhs: AwardsLoadState, rhs: AwardsLoadState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading), (.empty, .empty): return true
        case let (.loaded(a), .loaded(b)): return a.map(\.id) == b.map(\.id)
        case let (.error(a), .error(b)): return a == b
        default: return false
        }
    }
}
