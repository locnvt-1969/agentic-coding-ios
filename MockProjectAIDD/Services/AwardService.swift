// AwardService.swift
// MockProjectAIDD
//
// Awards domain. Stubbed until Supabase SDK is wired.

import Foundation

enum AwardError: LocalizedError {
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .loadFailed(let msg): return msg
        }
    }
}

@MainActor
final class AwardService {
    static let shared = AwardService()
    private init() {}

    func fetchAwards(userId: String) async throws -> [Award] {
        // TODO: Supabase — awards earned by user.
        return []
    }

    func awardDetail(type: AwardType) async throws -> Award {
        // TODO: Supabase — award detail by type.
        return Award(id: type.rawValue, type: type)
    }
}
