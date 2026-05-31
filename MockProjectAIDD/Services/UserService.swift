// UserService.swift
// MockProjectAIDD
//
// User/directory domain. Stubbed with mock data until Supabase SDK is wired
// (mirrors AuthService pattern). Mock content sourced from the design.

import Foundation

enum UserError: LocalizedError {
    case notFound
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .notFound: return "User not found."
        case .loadFailed(let msg): return msg
        }
    }
}

@MainActor
final class UserService {
    static let shared = UserService()
    private init() {}

    func fetchCurrentUser() async throws -> User {
        // TODO: Supabase — fetch authenticated user profile.
        // Mock (from design): self profile — icon collection still empty.
        return User(
            id: "me",
            name: "Huỳnh Dương Xuân Nhật",
            departmentName: "CEVC3",
            role: "Engineer",
            level: "Legend Hero",
            collectedValueIcons: []
        )
    }

    func fetchUser(id: String) async throws -> User {
        // TODO: Supabase — fetch user by id.
        // Mock: look the user up in the directory so the opened profile matches
        // the tapped search result; fall back to a full-collection sample.
        return Self.directory.first { $0.id == id } ?? User(
            id: id,
            name: "Huỳnh Dương Xuân Nhật",
            departmentName: "CEVC3",
            role: "Engineer",
            level: "Rising Hero",
            collectedValueIcons: SunValueIcon.allCases
        )
    }

    func fetchProfileStats(userId: String?) async throws -> ProfileStatsData {
        // TODO: Supabase — aggregate profile stats for the given user (nil = current user).
        // Mock values taken from the design.
        return ProfileStatsData(
            kudosReceived: 5,
            kudosSent: 25,
            heartsReceived: 25,
            secretBoxOpened: 25,
            secretBoxUnopened: 25
        )
    }

    func searchSunners(query: String) async throws -> [User] {
        // TODO: Supabase — full-text user search.
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return [] }
        let matches = Self.directory.filter {
            $0.name.localizedCaseInsensitiveContains(trimmed)
                || ($0.departmentName?.localizedCaseInsensitiveContains(trimmed) ?? false)
        }
        // For the mock demo, any non-empty query surfaces the directory if nothing matched.
        return matches.isEmpty ? Self.directory : matches
    }

    func listDepartments() async throws -> [Department] {
        // TODO: Supabase — list departments.
        return []
    }

    /// Mock sunner directory (from design). Drives search results + other-user profiles.
    private static let directory: [User] = [
        User(id: "u-101", name: "Huỳnh Dương Xuân Nhật", departmentName: "CEVC3", role: "Engineer",
             level: "Rising Hero", collectedValueIcons: SunValueIcon.allCases),
        User(id: "u-102", name: "Dương Xuân Huỳnh", departmentName: "CEVC10", role: "Engineer",
             level: "Legend Hero", collectedValueIcons: SunValueIcon.allCases),
        User(id: "u-103", name: "Nguyễn Bá Chức", departmentName: "CEVC10", role: "Engineer",
             level: "Rising Hero", collectedValueIcons: Array(SunValueIcon.allCases.prefix(4))),
        User(id: "u-104", name: "Trần Thị Mai", departmentName: "CEVC5", role: "Designer",
             level: "New Hero", collectedValueIcons: Array(SunValueIcon.allCases.prefix(2))),
        User(id: "u-105", name: "Lê Văn Phúc", departmentName: "CEVC7", role: "Engineer",
             level: "Rising Hero", collectedValueIcons: SunValueIcon.allCases)
    ]
}
