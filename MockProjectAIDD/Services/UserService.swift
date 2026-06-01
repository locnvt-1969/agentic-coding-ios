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

    func searchSunners(query: String) async throws -> [User] {
        // Strip PostgREST ilike wildcards (*, .) so a "*"-only query can't dump the directory.
        let q = query.trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "*", with: "")
            .replacingOccurrences(of: ".", with: "")
        guard !q.isEmpty else { return [] }
        let rows = try await SupabaseRESTClient.shared.get(
            "profiles",
            query: [
                URLQueryItem(name: "select", value: "id,full_name,avatar_url,role,departments(name)"),
                URLQueryItem(name: "full_name", value: "ilike.*\(q)*"),
                URLQueryItem(name: "limit", value: "20")
            ],
            as: [SunnerRow].self
        )
        return rows.map {
            User(id: $0.id, name: $0.fullName,
                 avatarURL: $0.avatarUrl.flatMap { URL(string: $0) },
                 departmentName: $0.departments?.name, role: $0.role)
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

    /// Decode shape for the sunner search (profiles row + embedded department).
    private struct SunnerRow: Decodable {
        let id: String
        let fullName: String
        let avatarUrl: String?
        let role: String?
        let departments: Dept?
        struct Dept: Decodable { let name: String }
    }
}
