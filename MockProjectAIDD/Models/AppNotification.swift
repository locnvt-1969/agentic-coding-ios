// AppNotification.swift
// MockProjectAIDD

import Foundation

struct AppNotification: Identifiable, Hashable, Codable {
    enum Kind: String, Codable, Hashable {
        case kudoReceived
        case kudoReaction
        case awardGranted
        case system
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
