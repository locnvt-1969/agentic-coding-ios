// NotificationsViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class NotificationsViewModel {
    var items: [AppNotification] = []
    var unreadCount = 0
    var isLoading = false
    var errorMessage: String?

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            items = try await NotificationService.shared.listNotifications()
            unreadCount = try await NotificationService.shared.unreadCount()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markRead(_ notification: AppNotification) async {
        do {
            try await NotificationService.shared.markRead(id: notification.id)
            if let idx = items.firstIndex(where: { $0.id == notification.id }) {
                items[idx].isRead = true
            }
            unreadCount = max(0, unreadCount - 1)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markAllRead() async {
        for item in items where !item.isRead {
            await markRead(item)
        }
    }
}
