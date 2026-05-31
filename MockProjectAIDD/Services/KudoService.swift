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
        // TODO: Supabase — board feed with filter. Mock data: KudoService+Mock.swift.
        var result = Self.mockKudos

        if let hashtagId = filter.hashtagId {
            result = result.filter { kudo in
                kudo.hashtags.contains { $0.id == hashtagId }
            }
        }

        // Department filter matches the recipient's department name (mock kudos carry
        // departmentName; resolve the selected id → name via the shared dept list).
        if let departmentId = filter.departmentId,
           let departmentName = UserService.mockDepartments.first(where: { $0.id == departmentId })?.name {
            result = result.filter { kudo in
                kudo.recipients.contains { $0.departmentName == departmentName }
            }
        }

        return result
    }

    func listAllKudos(page: Int = 0) async throws -> [Kudo] {
        // TODO: Supabase — paginated all kudos.
        // Mock feed (from design). Page 0 returns the sample list; later pages are empty.
        guard page == 0 else { return [] }
        return Self.mockFeed
    }

    /// Mock kudos feed sourced from the design content. Replaced by the API later.
    private static let mockFeed: [Kudo] = {
        let sender = User(id: "s1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10", level: "Rising Hero")
        let recipient = User(id: "r1", name: "Dương Xuân Huỳnh", departmentName: "CEVC10", level: "Legend Hero")
        let date = ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(timeIntervalSince1970: 0)
        let hashtags = [
            Hashtag(id: "h1", name: "#Dedicated", group: nil),
            Hashtag(id: "h2", name: "#Inspring", group: nil)
        ]
        let message = "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất..."

        return (0..<5).map { index in
            Kudo(
                id: "kudo-\(index)",
                sender: sender,
                recipients: [recipient],
                message: message,
                hashtags: hashtags,
                isAnonymous: false,
                createdAt: date,
                reactionCount: 1000,
                isHighlighted: true,
                isSpam: index == 0   // first card flagged Spam (per design)
            )
        }
    }()

    func viewKudo(id: String) async throws -> Kudo {
        // TODO: Supabase — fetch kudo by id.
        guard let kudo = Self.mockKudos.first(where: { $0.id == id }) else {
            throw KudoError.notFound
        }
        return kudo
    }

    func sendKudo(_ payload: SendKudoPayload) async throws {
        // TODO: Supabase — insert kudo.
        throw KudoError.sendFailed("Kudos backend not yet configured.")
    }

    func listHashtags() async throws -> [Hashtag] {
        // TODO: Supabase — list hashtags.
        return Self.mockHashtags
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
