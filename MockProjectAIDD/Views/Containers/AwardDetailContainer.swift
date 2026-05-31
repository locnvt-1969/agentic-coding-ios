// AwardDetailContainer.swift
// MockProjectAIDD
//
// Container: wires AwardsViewModel → AwardDetailView for a specific award type.
// Phase-19 integration.

import SwiftUI

struct AwardDetailContainer: View {
    let type: AwardType

    @State private var vm = AwardsViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            if let award = vm.award {
                AwardDetailView(
                    award: award,
                    onBack: {
                        router.pop()
                    }
                )
            } else if vm.errorMessage != nil {
                ContainerErrorView(
                    message: vm.errorMessage ?? "",
                    onRetry: { Task { await vm.load(type: type) } },
                    onBack: { router.pop() }
                )
            } else {
                loadingView
            }
        }
        .task {
            await vm.load(type: type)
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

    private var loadingView: some View {
        ZStack {
            Color.awardDark.ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
        }
    }
}
