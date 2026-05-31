// ProfileSelfContainer.swift
// MockProjectAIDD
//
// Container: wires ProfileViewModel → ProfileSelfView for the current user's profile.
// Phase-19 integration.

import SwiftUI

struct ProfileSelfContainer: View {
    @State private var vm = ProfileViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            if let user = vm.user {
                ProfileSelfView(
                    user: user,
                    awards: vm.awards,
                    onEdit: {
                        // TODO phase-19+: wire edit profile navigation when screen exists
                    },
                    onOpenAward: { type in
                        router.push(.awardDetail(type: type))
                    },
                    kudos: vm.kudos,
                    kudosReceivedCount: vm.kudosReceivedCount,
                    kudosSentCount: vm.kudosSentCount,
                    onOpenSecretBox: {
                        router.push(.secretBox)
                    },
                    onCopyKudoLink: { _ in
                        // TODO phase-19+: implement kudo link copy via pasteboard
                    },
                    onViewKudoDetail: { kudo in
                        router.push(.viewKudo(id: kudo.id))
                    }
                )
            } else if vm.errorMessage != nil {
                ContainerErrorView(
                    message: vm.errorMessage ?? "",
                    onRetry: { Task { await vm.load(userId: nil) } }
                    // Back is a no-op for tab-root; omit to hide the button cleanly
                )
            } else {
                loadingView
            }
        }
        .task {
            await vm.load(userId: nil)
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
