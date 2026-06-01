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

    /// Mock org departments — drives the Kudos board "Phòng ban" filter dropdown.
    /// TEMPORARY: replace with a Supabase fetch (`GET /api/v1/departments`) later.
    static let mockDepartments: [Department] = [
        Department(id: "d1", name: "CEVC2"),
        Department(id: "d2", name: "CEVC3"),
        Department(id: "d3", name: "CEVC4"),
        Department(id: "d4", name: "CEVC1"),
        Department(id: "d5", name: "OPD"),
        Department(id: "d6", name: "Infra")
    ]

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
        // TODO: Supabase — list departments.
        return Self.mockDepartments
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
