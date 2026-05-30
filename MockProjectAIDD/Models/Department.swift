// Department.swift
// MockProjectAIDD

import Foundation

struct Department: Identifiable, Hashable, Codable {
    let id: String
    let name: String

    static let sample = Department(id: "d1", name: "Engineering")
}
