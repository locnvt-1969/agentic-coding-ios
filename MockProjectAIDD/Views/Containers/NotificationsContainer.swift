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
            onTap: { _ in
                // TODO phase-19+: route per notification kind when deep-link targets are defined
            },
            onMarkAllRead: {
                Task { await vm.markAllRead() }
            },
            onBack: {
                router.pop()
            }
        )
        .task {
            await vm.load()
        }
        .alert("Lỗi", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
