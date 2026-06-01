// ViewKudoContainer.swift
// MockProjectAIDD
//
// Container: wires ViewKudoViewModel → ViewKudoView for a specific kudo.
// Anonymity is respected via kudo.resolvedSender — never reads kudo.sender directly.
// Phase-19 integration.

import SwiftUI

struct ViewKudoContainer: View {
    let kudoId: String

    @State private var vm = ViewKudoViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            if let kudo = vm.kudo {
                ViewKudoView(
                    kudo: kudo,
                    onBack: {
                        router.pop()
                    },
                    onComment: { text in
                        await vm.addComment(text)
                    },
                    onReact: {
                        vm.toggleReaction()
                    }
                )
            } else if vm.errorMessage != nil {
                ContainerErrorView(
                    message: vm.errorMessage ?? "",
                    onRetry: { Task { await vm.load(id: kudoId) } },
                    onBack: { router.pop() }
                )
            } else {
                loadingView
            }
        }
        .task {
            await vm.load(id: kudoId)
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
            Color.kudosDark.ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
        }
    }
}
