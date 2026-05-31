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
        if FeatureFlags.useMockNotifications {
            // Demo: bundled mock notifications (real API wired later).
            try? await Task.sleep(nanoseconds: 300_000_000)
            items = NotificationsPreviewData.figmaSamples
            unreadCount = items.filter { !$0.isRead }.count
            return
        }
        do {
            items = try await NotificationService.shared.listNotifications()
            // Derive from items so the badge can't diverge from the list (avoids a stale
            // second round-trip); swap to a dedicated count endpoint only if needed.
            unreadCount = items.filter { !$0.isRead }.count
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func markRead(_ notification: AppNotification) async {
        if !FeatureFlags.useMockNotifications {
            do {
                try await NotificationService.shared.markRead(id: notification.id)
            } catch {
                errorMessage = error.localizedDescription
                return
            }
        }
        if let idx = items.firstIndex(where: { $0.id == notification.id }) {
            items[idx].isRead = true
        }
        unreadCount = items.filter { !$0.isRead }.count
    }

    func markAllRead() async {
        for item in items where !item.isRead {
            await markRead(item)
        }
    }
}
