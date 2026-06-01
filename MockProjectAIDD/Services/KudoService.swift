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
        var body: [String: Any] = ["p_limit": 50, "p_offset": 0]
        if let hashtagId = filter.hashtagId { body["p_hashtag"] = hashtagId }
        if let departmentId = filter.departmentId { body["p_department"] = departmentId }
        let dtos = try await SupabaseRESTClient.shared.callRPC(
            "list_kudos", body: body, as: [KudoDTO].self
        )
        return dtos.map { $0.toKudo() }
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
        let dto = try await SupabaseRESTClient.shared.callRPC(
            "view_kudo", body: ["p_id": id], as: KudoDTO?.self
        )
        guard let dto else { throw KudoError.notFound }
        return dto.toKudo()
    }

    /// Add the current user's ❤️ to a kudo (no-op-safe: unique(kudo_id, profile_id)).
    func react(kudoId: String) async throws {
        guard let uid = AuthService.shared.currentUserId else {
            throw KudoError.sendFailed("Bạn cần đăng nhập.")
        }
        try await SupabaseRESTClient.shared.insert("kudo_reactions", values: ["kudo_id": kudoId, "profile_id": uid])
    }

    /// Remove the current user's ❤️ from a kudo.
    func unreact(kudoId: String) async throws {
        guard let uid = AuthService.shared.currentUserId else {
            throw KudoError.sendFailed("Bạn cần đăng nhập.")
        }
        try await SupabaseRESTClient.shared.delete("kudo_reactions", query: [
            URLQueryItem(name: "kudo_id", value: "eq.\(kudoId)"),
            URLQueryItem(name: "profile_id", value: "eq.\(uid)")
        ])
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

    /// Add a comment to a kudo (author = signed-in user; RLS enforces author_id = auth.uid).
    func addComment(kudoId: String, text: String) async throws {
        guard let uid = AuthService.shared.currentUserId else {
            throw KudoError.sendFailed("Bạn cần đăng nhập để bình luận.")
        }
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        try await SupabaseRESTClient.shared.insert("kudo_comments", values: [
            "id": UUID().uuidString.lowercased(),
            "kudo_id": kudoId,
            "author_id": uid,
            "text": trimmed
        ])
    }

    /// Total Kudos count shown on the Spotlight Board (design B.7.1).
    func spotlightTotalKudos() async throws -> Int {
        // Count from kudos_public (the same source the feed uses) so the total always
        // tracks what's shown. PostgREST returns it via Content-Range, no row transfer.
        try await SupabaseRESTClient.shared.count("kudos_public")
    }

    /// The current user's personal statistics (ALL KUDOS block, design D.1).
    func fetchPersonalStats() async throws -> KudosStats {
        guard let uid = AuthService.shared.currentUserId else {
            throw KudoError.loadFailed("Bạn cần đăng nhập.")
        }
        let rows = try await SupabaseRESTClient.shared.get(
            "v_profile_stats",
            query: [
                URLQueryItem(name: "select", value: "*"),
                URLQueryItem(name: "profile_id", value: "eq.\(uid)")
            ],
            as: [StatsRow].self
        )
        guard let s = rows.first else { throw KudoError.loadFailed("Không tìm thấy thống kê.") }
        // isDoubleBonusActive is an admin-configured special-day flag — no DB source yet.
        return KudosStats(
            kudosReceived: s.kudosReceived,
            kudosSent: s.kudosSent,
            heartsReceived: s.heartsReceived,
            isDoubleBonusActive: false,
            secretBoxesOpened: s.secretBoxOpened,
            secretBoxesUnopened: s.secretBoxUnopened
        )
    }

    /// 10 most recent gift recipients (design D.3) — owner-rights view bypasses user_rewards RLS.
    func listGiftRecipients() async throws -> [GiftRecipient] {
        try await SupabaseRESTClient.shared.get(
            "v_recent_gift_recipients",
            query: [URLQueryItem(name: "select", value: "*")],
            as: [GiftRecipient].self
        )
    }

    /// Decodes a row of `v_profile_stats` (snake_case → camelCase via the shared decoder).
    private struct StatsRow: Decodable {
        let kudosReceived: Int
        let kudosSent: Int
        let heartsReceived: Int
        let secretBoxOpened: Int
        let secretBoxUnopened: Int
    }
}
