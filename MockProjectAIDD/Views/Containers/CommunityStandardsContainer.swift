// CommunityStandardsContainer.swift
// MockProjectAIDD
//
// Container: wires ContentViewModel.loadCommunityStandards() → CommunityStandardsView.
// Phase-19 integration.

import SwiftUI

struct CommunityStandardsContainer: View {
    @State private var vm = ContentViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            if let standard = vm.communityStandard {
                CommunityStandardsView(
                    standard: standard,
                    onBack: {
                        router.pop()
                    }
                )
            } else if vm.errorMessage != nil {
                ContainerErrorView(
                    message: vm.errorMessage ?? "",
                    onRetry: { Task { await vm.loadCommunityStandards() } },
                    onBack: { router.pop() }
                )
            } else {
                loadingView
            }
        }
        .task {
            await vm.loadCommunityStandards()
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
            Color(hex: "00101A").ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
        }
    }
}
