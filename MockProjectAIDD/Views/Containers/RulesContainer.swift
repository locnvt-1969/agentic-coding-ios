// RulesContainer.swift
// MockProjectAIDD
//
// Container: wires ContentViewModel.loadRules() → RulesView.
// Phase-19 integration.

import SwiftUI

struct RulesContainer: View {
    @State private var vm = ContentViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            if let rule = vm.rule {
                RulesView(
                    rule: rule,
                    onClose: {
                        router.pop()
                    },
                    onWriteKudos: {
                        router.push(.sendKudo)
                    }
                )
            } else if vm.errorMessage != nil {
                ContainerErrorView(
                    message: vm.errorMessage ?? "",
                    onRetry: { Task { await vm.loadRules() } },
                    onBack: { router.pop() }
                )
            } else {
                loadingView
            }
        }
        .task {
            await vm.loadRules()
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
