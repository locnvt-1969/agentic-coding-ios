// SecretBox.swift
// MockProjectAIDD

import Foundation

struct Gift: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let detail: String?

    static let sample = Gift(id: "g1", title: "Surprise reward", detail: nil)
}

struct SecretBox: Hashable, Codable {
    enum State: String, Codable, Hashable {
        case closed       // not yet opened
        case opening      // user tapped to open (action bấm mở)
        case standby      // opened, awaiting reveal / standby
    }

    var state: State
    var reward: Gift?

    static let sample = SecretBox(state: .closed, reward: nil)
}
