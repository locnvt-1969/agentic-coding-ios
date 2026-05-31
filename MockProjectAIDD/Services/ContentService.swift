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
        do {
            let sections = try await SupabaseRESTClient.shared.get(
                "content_sections",
                query: [
                    URLQueryItem(name: "document_id", value: "eq.community_standards"),
                    URLQueryItem(name: "order", value: "display_order.asc"),
                    URLQueryItem(name: "select", value: "*")
                ],
                as: [ContentSection].self
            )
            return CommunityStandard(sections: sections)
        } catch {
            throw ContentError.loadFailed(error.localizedDescription)
        }
    }

    func rules() async throws -> Rule {
        // Title is the document name; the Rules screen also composes hero tiers + value icons.
        do {
            let sections = try await SupabaseRESTClient.shared.get(
                "content_sections",
                query: [
                    URLQueryItem(name: "document_id", value: "eq.rules"),
                    URLQueryItem(name: "order", value: "display_order.asc"),
                    URLQueryItem(name: "select", value: "*")
                ],
                as: [ContentSection].self
            )
            return Rule(title: "Thể lệ", sections: sections)
        } catch {
            throw ContentError.loadFailed(error.localizedDescription)
        }
    }
}
