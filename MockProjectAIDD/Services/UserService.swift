// UserService.swift
// MockProjectAIDD
//
// User/directory domain. Stubbed until Supabase SDK is wired (mirrors AuthService pattern).

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
        return .sample
    }

    func fetchUser(id: String) async throws -> User {
        // TODO: Supabase — fetch user by id.
        return User(id: id, name: "Sunner")
    }

    func searchSunners(query: String) async throws -> [User] {
        // TODO: Supabase — full-text user search.
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return [] }
        return []
    }

    func listDepartments() async throws -> [Department] {
        // TODO: Supabase — list departments.
        return []
    }
}
