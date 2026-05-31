// AppNotification.swift
// MockProjectAIDD

import Foundation

struct AppNotification: Identifiable, Hashable, Codable {
    /// 7 notification types from the Figma spec — each drives a distinct icon/color.
    enum Kind: String, Codable, Hashable {
        case kudoReceived     // envelope (blue)   — a Sunner sent you a kudo
        case kudoReaction     // heart (pink)      — your kudo received a reaction
        case secretBox        // gift (green)      — a Secret Box unlock is available
        case levelUp          // star (yellow)     — you reached a new Hero level
        case contentHidden    // warning (amber)   — a kudo was hidden (violated standards)
        case badgeCollected   // shield (blue)     — you collected all badges
        case reviewRequest    // pen (purple)      — admin: a kudo needs review
    }

    let id: String
    let kind: Kind
    let actor: User?
    let message: String
    let createdAt: Date
    var isRead: Bool

    static let sample = AppNotification(
        id: "n1",
        kind: .kudoReceived,
        actor: .sample,
        message: "sent you a kudo",
        createdAt: Date(timeIntervalSince1970: 0),
        isRead: false
    )
}
