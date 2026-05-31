// SecretBoxContainer.swift
// MockProjectAIDD
//
// Container: wires SecretBoxViewModel → SecretBoxView.
// Phase-19 integration — NEW FILE.

import SwiftUI

@MainActor
struct SecretBoxContainer: View {
    @State private var vm = SecretBoxViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            SecretBoxView(
                state: vm.box.state,
                reward: vm.box.reward,
                onOpen: {
                    Task { await vm.open() }
                },
                onBack: {
                    router.pop()
                }
            )

            if vm.isLoading && vm.box.state == .closed {
                loadingOverlay
            }
        }
        .task {
            await vm.load()
        }
        .alert("Lỗi", isPresented: .constant(vm.errorMessage != nil)) {
            Button("OK") { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.secretBoxDark.opacity(0.7).ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
        }
    }
}
