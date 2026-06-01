// AllKudosContainer.swift
// MockProjectAIDD
//
// Container: wires AllKudosViewModel → AllKudosView.
// Phase-19 integration — NEW FILE.

import SwiftUI

@MainActor
struct AllKudosContainer: View {
    @State private var vm = AllKudosViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            AllKudosView(
                kudos: vm.kudos,
                onOpenKudo: { kudo in
                    router.push(.viewKudo(id: kudo.id))
                },
                onLoadMore: {
                    Task { await vm.loadMore() }
                },
                onBack: {
                    router.pop()
                }
            )

            if vm.isLoading && vm.kudos.isEmpty {
                loadingOverlay
            }
        }
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

    private var loadingOverlay: some View {
        ZStack {
            Color(hex: "00101A").opacity(0.85).ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
        }
    }
}
