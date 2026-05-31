// NotificationsContainer.swift
// MockProjectAIDD
//
// Container: wires NotificationsViewModel → NotificationsView.
// Phase-19 integration — NEW FILE.

import SwiftUI

@MainActor
struct NotificationsContainer: View {
    @State private var vm = NotificationsViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        NotificationsView(
            items: vm.items,
            isLoading: vm.isLoading,
            onTap: { notification in
                // Tap marks read (TC_NOTIF_FUN_001). Per-type deep navigation is deferred
                // until those targets/API are wired.
                Task { await vm.markRead(notification) }
            },
            onMarkAllRead: {
                Task { await vm.markAllRead() }
            },
            onCommunityStandards: {
                router.push(.communityStandards)
            },
            onBack: {
                router.pop()
            }
        )
        .task {
            await vm.load()
        }
        .alert(
            "Lỗi",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
