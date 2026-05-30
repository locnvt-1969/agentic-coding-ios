// ContentService.swift
// MockProjectAIDD
//
// Static content domain: Community Standards + Rules (Thể lệ).
// Stubbed until Supabase / remote content is wired.

import Foundation

enum ContentError: LocalizedError {
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .loadFailed(let msg): return msg
        }
    }
}

@MainActor
final class ContentService {
    static let shared = ContentService()
    private init() {}

    func communityStandards() async throws -> CommunityStandard {
        // TODO: Supabase / bundled content — community standards.
        return CommunityStandard(sections: [])
    }

    func rules() async throws -> Rule {
        // TODO: Supabase / bundled content — rules (Thể lệ).
        return Rule(title: "Thể lệ", sections: [])
    }
}
