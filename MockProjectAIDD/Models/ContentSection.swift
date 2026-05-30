// ContentSection.swift
// MockProjectAIDD
//
// Shared model for read-only content screens: Community Standards and Rules (Thể lệ).
// Both are sectioned long-form text, so they share one structure (DRY).

import Foundation

struct ContentSection: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let body: [String]   // paragraphs / bullet items

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
