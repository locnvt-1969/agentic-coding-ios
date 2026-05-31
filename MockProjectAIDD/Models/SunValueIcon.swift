// SunValueIcon.swift
// MockProjectAIDD
//
// The 6 Sun* value icons collected through Secret Boxes ("Bộ sưu tập icon").
// Asset names + labels match Assets.xcassets/Momorph/Content/rules_icon_* and the
// Rules screen (RulesContentSections). Shared by the Profile badge strip and Rules.

import Foundation

enum SunValueIcon: String, CaseIterable, Identifiable, Hashable, Codable {
    case revival
    case touchOfLight
    case stayGold
    case flowToHorizon
    case beyondTheBoundary
    case rootFurther

    var id: String { rawValue }

    /// Asset name under Assets.xcassets/Momorph/Content/.
    var imageName: String {
        switch self {
        case .revival:           return "rules_icon_revival"
        case .touchOfLight:      return "rules_icon_touch_of_light"
        case .stayGold:          return "rules_icon_stay_gold"
        case .flowToHorizon:     return "rules_icon_flow_to_horizon"
        case .beyondTheBoundary: return "rules_icon_beyond_boundary"
        case .rootFurther:       return "rules_icon_root_further"
        }
    }

    /// Display label shown under each icon (design uses uppercase).
    var label: String {
        switch self {
        case .revival:           return "REVIVAL"
        case .touchOfLight:      return "TOUCH OF LIGHT"
        case .stayGold:          return "STAY GOLD"
        case .flowToHorizon:     return "FLOW TO HORIZON"
        case .beyondTheBoundary: return "BEYOND THE BOUNDARY"
        case .rootFurther:       return "ROOT FURTHER"
        }
    }

    /// Database slug (snake_case) used by Supabase `value_icons.id` / `value_icon_ids`.
    var dbId: String {
        switch self {
        case .revival:           return "revival"
        case .touchOfLight:      return "touch_of_light"
        case .stayGold:          return "stay_gold"
        case .flowToHorizon:     return "flow_to_horizon"
        case .beyondTheBoundary: return "beyond_the_boundary"
        case .rootFurther:       return "root_further"
        }
    }

    /// Build from a database slug (e.g. "touch_of_light"); nil if unknown.
    init?(dbId: String) {
        guard let match = Self.allCases.first(where: { $0.dbId == dbId }) else { return nil }
        self = match
    }
}
