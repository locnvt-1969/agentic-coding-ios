// SecretBoxService.swift
// MockProjectAIDD
//
// Secret box / gift domain. Stubbed until Supabase SDK is wired.

import Foundation

enum SecretBoxError: LocalizedError {
    case openFailed(String)

    var errorDescription: String? {
        switch self {
        case .openFailed(let msg): return msg
        }
    }
}

@MainActor
final class SecretBoxService {
    static let shared = SecretBoxService()
    private init() {}

    func currentBox() async throws -> SecretBox {
        // TODO: Supabase — current secret box state for user.
        return .sample
    }

    func openBox() async throws -> Gift {
        // TODO: Supabase — open box and return reward.
        throw SecretBoxError.openFailed("Secret box backend not yet configured.")
    }
}
