// UserService.swift
// MockProjectAIDD
//
// User/directory domain — wired to Supabase via raw REST (get_profile RPC,
// v_profile_stats, profiles search, departments).

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
        guard let uid = AuthService.shared.currentUserId else { throw UserError.notFound }
        let dto = try await SupabaseRESTClient.shared.callRPC(
            "get_profile", body: ["p_id": uid], as: ProfileDTO?.self
        )
        guard let dto else { throw UserError.notFound }
        return dto.toUser()
    }

    func fetchUser(id: String) async throws -> User {
        let dto = try await SupabaseRESTClient.shared.callRPC(
            "get_profile", body: ["p_id": id], as: ProfileDTO?.self
        )
        guard let dto else { throw UserError.notFound }
        return dto.toUser()
    }

    func fetchProfileStats(userId: String?) async throws -> ProfileStatsData {
        guard let id = userId ?? AuthService.shared.currentUserId else { throw UserError.notFound }
        let rows = try await SupabaseRESTClient.shared.get(
            "v_profile_stats",
            query: [
                URLQueryItem(name: "profile_id", value: "eq.\(id)"),
                URLQueryItem(name: "select", value: "*")
            ],
            as: [ProfileStatsData].self
        )
        return rows.first ?? .zero
    }

    /// Diacritic-insensitive Sunner search via the search_profiles RPC (so "Nguyen"
    /// matches "Nguyễn"). An empty query returns the first page of the directory —
    /// used to populate the recipient picker before the user types.
    func searchSunners(query: String) async throws -> [User] {
        let rows = try await SupabaseRESTClient.shared.callRPC(
            "search_profiles",
            body: ["p_query": query.trimmingCharacters(in: .whitespaces), "p_limit": 50],
            as: [SunnerRow].self
        )
        return rows.map {
            User(id: $0.id, name: $0.fullName,
                 avatarURL: $0.avatarUrl.flatMap { URL(string: $0) },
                 departmentName: $0.departmentName, role: $0.role)
        }
    }

    func listDepartments() async throws -> [Department] {
        try await SupabaseRESTClient.shared.get(
            "departments",
            query: [
                URLQueryItem(name: "select", value: "id,name"),
                URLQueryItem(name: "order", value: "name.asc")
            ],
            as: [Department].self
        )
    }

    /// Decode shape for the search_profiles RPC (flat row, snake_case → camelCase).
    private struct SunnerRow: Decodable {
        let id: String
        let fullName: String
        let avatarUrl: String?
        let role: String?
        let departmentName: String?
    }
}
