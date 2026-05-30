// Hashtag.swift
// MockProjectAIDD

import Foundation

struct Hashtag: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let group: String?

    static let sample = Hashtag(id: "h1", name: "#teamwork", group: "Values")
}
