// User.swift
// MockProjectAIDD

import Foundation

struct User: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let avatarURL: URL?
    let departmentName: String?
    let role: String?
    let level: String?
    /// Award types this user has earned (drives profile badges/awards strip).
    let awardTypes: [AwardType]

    init(
        id: String,
        name: String,
        avatarURL: URL? = nil,
        departmentName: String? = nil,
        role: String? = nil,
        level: String? = nil,
        awardTypes: [AwardType] = []
    ) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.departmentName = departmentName
        self.role = role
        self.level = level
        self.awardTypes = awardTypes
    }

    static let sample = User(
        id: "u1",
        name: "Sunner",
        departmentName: "Engineering",
        role: "Engineer",
        level: "Senior",
        awardTypes: [.mvp]
    )
}
