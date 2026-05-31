// HomeModels.swift
// MockProjectAIDD
//
// Plain data models for the Home screen — no business logic.

import Foundation

// MARK: - Countdown

/// Countdown value exposed as a prop. Includes event-phase flags driven by CountdownTimer.
struct CountdownValue {
    let days: Int
    let hours: Int
    let minutes: Int
    let comingSoonVisible: Bool
    let eventEnded: Bool

    static let placeholder = CountdownValue(
        days: 20,
        hours: 20,
        minutes: 20,
        comingSoonVisible: true,
        eventEnded: false
    )
}

// MARK: - Award

struct AwardItem: Identifiable {
    let id: String
    let thumbnailName: String   // Asset catalog name (Momorph/Home/)
    let name: String
    let description: String
}

// MARK: - Home Tab

enum HomeTab: String, CaseIterable, Identifiable {
    case saa2025 = "SAA 2025"
    case awards  = "Awards"
    case kudos   = "Kudos"
    case profile = "Profile"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .saa2025:  return "house.fill"
        case .awards:   return "trophy"
        case .kudos:    return "hands.sparkles"
        case .profile:  return "person"
        }
    }
}
