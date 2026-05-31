// AwardDetailContainer.swift
// MockProjectAIDD
//
// Container: wires AwardsViewModel → AwardDetailView for a specific award type.
// Phase-19 integration.

import SwiftUI

struct AwardDetailContainer: View {
    /// Award shown first. As a tab root this defaults to Top Talent; when pushed
    /// from Home it's the tapped award.
    var initialType: AwardType = .topTalent
    /// Tab root hides the back button; pushed presentation shows it.
    var showsBack: Bool = false

    @State private var vm = AwardsViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            if let award = vm.award {
                AwardDetailView(
                    award: award,
                    availableTypes: vm.availableTypes,
                    onSelectType: { vm.select($0) },
                    onBack: showsBack ? { router.pop() } : nil,
                    onSearch: { router.push(.searchSunner) },
                    onNotifications: { router.push(.notifications) },
                    onKudosDetail: { router.push(.kudosBoard) }
                )
            } else if vm.errorMessage != nil {
                ContainerErrorView(
                    message: vm.errorMessage ?? "",
                    onRetry: { Task { await vm.load(type: vm.selectedType) } },
                    onBack: showsBack ? { router.pop() } : nil
                )
            } else {
                loadingView
            }
        }
        .task {
            if vm.award == nil { await vm.load(type: initialType) }
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
