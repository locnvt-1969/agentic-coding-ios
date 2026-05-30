// Award.swift
// MockProjectAIDD

import Foundation

struct Award: Identifiable, Hashable, Codable {
    let id: String
    let type: AwardType
    let recipientName: String?
    /// Criteria / description lines shown on the detail screen.
    let criteria: [String]

    init(id: String, type: AwardType, recipientName: String? = nil, criteria: [String] = []) {
        self.id = id
        self.type = type
        self.recipientName = recipientName
        self.criteria = criteria
    }

    static let sample = Award(id: "a1", type: .mvp, recipientName: "Sunner", criteria: [])
}
