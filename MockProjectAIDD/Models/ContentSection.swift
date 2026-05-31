// ContentSection.swift
// MockProjectAIDD
//
// Shared model for read-only content screens: Community Standards and Rules (Thể lệ).
// Both are sectioned long-form text, so they share one structure (DRY).

import Foundation

struct ContentSection: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let body: [String]              // regular paragraphs (white)
    /// Bold-white intro line rendered above the body (optional).
    let leadParagraph: String?
    /// Ordered list rendered "1. … 2. …" with hanging indent (optional).
    let numberedItems: [String]
    /// Bulleted list rendered with "•" markers (optional).
    let bulletItems: [String]
    /// Gold-bold emphasis line rendered at the end, e.g. a contact note (optional).
    let highlight: String?

    init(
        id: String,
        title: String,
        body: [String] = [],
        leadParagraph: String? = nil,
        numberedItems: [String] = [],
        bulletItems: [String] = [],
        highlight: String? = nil
    ) {
        self.id = id
        self.title = title
        self.body = body
        self.leadParagraph = leadParagraph
        self.numberedItems = numberedItems
        self.bulletItems = bulletItems
        self.highlight = highlight
    }

    static let sample = ContentSection(id: "s1", title: "Section", body: ["Content line."])
}

/// Community Standards document.
struct CommunityStandard: Hashable, Codable {
    let sections: [ContentSection]
    static let sample = CommunityStandard(sections: [.sample])
}

/// Rules (Thể lệ) document.
struct Rule: Hashable, Codable {
    let title: String
    let sections: [ContentSection]
    static let sample = Rule(title: "Thể lệ", sections: [.sample])
}
