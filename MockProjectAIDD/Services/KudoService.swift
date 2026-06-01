// KudoService.swift
// MockProjectAIDD
//
// Kudos domain. Stubbed until Supabase SDK is wired.

import Foundation

enum KudoError: LocalizedError {
    case sendFailed(String)
    case loadFailed(String)
    case notFound

    var errorDescription: String? {
        switch self {
        case .sendFailed(let msg): return msg
        case .loadFailed(let msg): return msg
        case .notFound: return "Kudo not found."
        }
    }
}

/// Filter applied to the kudos board.
struct KudoFilter: Hashable {
    var hashtagId: String?
    var departmentId: String?
    nonisolated init(hashtagId: String? = nil, departmentId: String? = nil) {
        self.hashtagId = hashtagId
        self.departmentId = departmentId
    }
}

/// Payload for composing a kudo (Track A SendKudo view binds to this).
struct SendKudoPayload: Hashable {
    var recipient: User
    var title: String
    var message: String
    var hashtags: [Hashtag]
    var isAnonymous: Bool
}

@MainActor
final class KudoService {
    static let shared = KudoService()
    private init() {}

    func listKudos(filter: KudoFilter = KudoFilter()) async throws -> [Kudo] {
        // TODO: server-side filter (needs hashtags/departments wired to DB) — for now the
        // board shows the full feed regardless of the selected filter.
        return try await listAllKudos(page: 0)
    }

    func listAllKudos(page: Int = 0) async throws -> [Kudo] {
        let pageSize = 20
        let dtos = try await SupabaseRESTClient.shared.callRPC(
            "list_kudos",
            body: ["p_limit": pageSize, "p_offset": page * pageSize],
            as: [KudoDTO].self
        )
        return dtos.map { $0.toKudo() }
    }

    /// Kudos received by a specific user — drives the profile's kudos section.
    func listReceivedKudos(userId: String) async throws -> [Kudo] {
        let dtos = try await SupabaseRESTClient.shared.callRPC(
            "list_kudos",
            body: ["p_limit": 50, "p_offset": 0, "p_recipient": userId],
            as: [KudoDTO].self
        )
        return dtos.map { $0.toKudo() }
    }

    func viewKudo(id: String) async throws -> Kudo {
        // TODO: Supabase — fetch kudo by id.
        guard let kudo = Self.mockKudos.first(where: { $0.id == id }) else {
            throw KudoError.notFound
        }
        return kudo
    }

    func sendKudo(_ payload: SendKudoPayload) async throws {
        guard let senderId = AuthService.shared.currentUserId else {
            throw KudoError.sendFailed("Bạn cần đăng nhập để gửi Kudos.")
        }
        let kudoId = UUID().uuidString.lowercased()
        try await SupabaseRESTClient.shared.insert("kudos", values: [
            "id": kudoId,
            "sender_id": senderId,
            "recipient_id": payload.recipient.id,
            "title": payload.title,
            "message": payload.message,
            "is_anonymous": payload.isAnonymous
        ])
        if !payload.hashtags.isEmpty {
            let rows = payload.hashtags.map { ["kudo_id": kudoId, "hashtag_id": $0.id] }
            try await SupabaseRESTClient.shared.insert("kudo_hashtags", values: rows)
        }
    }

    func listHashtags() async throws -> [Hashtag] {
        try await SupabaseRESTClient.shared.get(
            "hashtags",
            query: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "order", value: "name.asc")
            ],
            as: [Hashtag].self
        )
    }

    /// Total Kudos count shown on the Spotlight Board (design B.7.1).
    func spotlightTotalKudos() async throws -> Int {
        // TODO: Supabase — SELECT count(*) FROM kudos WHERE status='active'.
        return Self.mockSpotlightTotal
    }

    /// The current user's personal statistics (ALL KUDOS block, design D.1).
    func fetchPersonalStats() async throws -> KudosStats {
        // TODO: Supabase — GET /api/v1/users/me/kudos-stats.
        return Self.mockStats
    }

    /// 10 most recent gift recipients (design D.3).
    func listGiftRecipients() async throws -> [GiftRecipient] {
        // TODO: Supabase — GET /api/v1/reward-recipients?limit=10&order=desc.
        return Self.mockGiftRecipients
    }
}
