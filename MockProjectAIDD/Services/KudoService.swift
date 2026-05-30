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
    init(hashtagId: String? = nil, departmentId: String? = nil) {
        self.hashtagId = hashtagId
        self.departmentId = departmentId
    }
}

/// Payload for composing a kudo (Track A SendKudo view binds to this).
struct SendKudoPayload: Hashable {
    var recipients: [User]
    var message: String
    var hashtags: [Hashtag]
    var isAnonymous: Bool
}

@MainActor
final class KudoService {
    static let shared = KudoService()
    private init() {}

    func listKudos(filter: KudoFilter = KudoFilter()) async throws -> [Kudo] {
        // TODO: Supabase — board feed with filter.
        return []
    }

    func listAllKudos(page: Int = 0) async throws -> [Kudo] {
        // TODO: Supabase — paginated all kudos.
        return []
    }

    func viewKudo(id: String) async throws -> Kudo {
        // TODO: Supabase — fetch kudo by id.
        throw KudoError.notFound
    }

    func sendKudo(_ payload: SendKudoPayload) async throws {
        // TODO: Supabase — insert kudo.
        throw KudoError.sendFailed("Kudos backend not yet configured.")
    }

    func listHashtags() async throws -> [Hashtag] {
        // TODO: Supabase — list hashtags.
        return []
    }
}
