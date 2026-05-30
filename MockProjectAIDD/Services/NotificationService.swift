// NotificationService.swift
// MockProjectAIDD
//
// Notifications domain. Stubbed until Supabase SDK is wired.

import Foundation

enum NotificationError: LocalizedError {
    case loadFailed(String)

    var errorDescription: String? {
        switch self {
        case .loadFailed(let msg): return msg
        }
    }
}

@MainActor
final class NotificationService {
    static let shared = NotificationService()
    private init() {}

    func listNotifications() async throws -> [AppNotification] {
        // TODO: Supabase — list notifications for current user.
        return []
    }

    func markRead(id: String) async throws {
        // TODO: Supabase — mark a notification read.
    }

    func unreadCount() async throws -> Int {
        // TODO: Supabase — unread badge count.
        return 0
    }
}
