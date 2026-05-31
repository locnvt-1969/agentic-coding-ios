// ProfileOtherContainer.swift
// MockProjectAIDD
//
// Container: wires ProfileViewModel → ProfileOtherView for another user's profile.
// Phase-19 integration.

import SwiftUI

struct ProfileOtherContainer: View {
    let userId: String

    @State private var vm = ProfileViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            if let user = vm.user {
                ProfileOtherView(
                    user: user,
                    onSendKudo: {
                        router.push(.sendKudo)
                    },
                    kudos: vm.kudos,
                    kudosReceivedCount: vm.kudosReceivedCount,
                    onCopyKudoLink: { _ in
                        // TODO: implement kudo link copy via pasteboard
                    },
                    onViewKudoDetail: { kudo in
                        router.push(.viewKudo(id: kudo.id))
                    }
                )
            } else if vm.errorMessage != nil {
                ContainerErrorView(
                    message: vm.errorMessage ?? "",
                    onRetry: { Task { await vm.load(userId: userId) } },
                    onBack: { router.pop() }
                )
            } else {
                loadingView
            }
        }
        .task {
            await vm.load(userId: userId)
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
            Color.profileDark.ignoresSafeArea()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
        }
    }
}
