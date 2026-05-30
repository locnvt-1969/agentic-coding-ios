// KudoComment.swift
// MockProjectAIDD

import Foundation

struct KudoComment: Identifiable, Hashable, Codable {
    let id: String
    let author: User
    let text: String
    let createdAt: Date

    static let sample = KudoComment(id: "c1", author: .sample, text: "Congrats!", createdAt: Date(timeIntervalSince1970: 0))
}
