// KudosBoardContainer.swift
// MockProjectAIDD
//
// Container: wires KudosBoardViewModel → KudosBoardView.
// Phase-19 integration.

import SwiftUI

struct KudosBoardContainer: View {
    @State private var vm = KudosBoardViewModel()
    @State private var filterTask: Task<Void, Never>?
    @EnvironmentObject private var router: AppRouter

    /// Cancels any in-flight filter request before dispatching the next one,
    /// so rapid taps don't accumulate untracked tasks against a stale context.
    private func applyFilter(_ filter: KudoFilter) {
        filterTask?.cancel()
        filterTask = Task { await vm.apply(filter: filter) }
    }

    var body: some View {
        KudosBoardView(
            kudos: vm.kudos,
            hashtags: vm.hashtags,
            departments: vm.departments,
            stats: vm.stats,
            giftRecipients: vm.giftRecipients,
            spotlightTotal: vm.spotlightTotal,
            onSelectHashtag: { hashtag in
                applyFilter(KudoFilter(
                    hashtagId: hashtag?.id,
                    departmentId: vm.filter.departmentId
                ))
            },
            onSelectDepartment: { department in
                applyFilter(KudoFilter(
                    hashtagId: vm.filter.hashtagId,
                    departmentId: department?.id
                ))
            },
            onOpenKudo: { kudo in
                router.push(.viewKudo(id: kudo.id))
            },
            onSendKudo: {
                router.push(.sendKudo)
            },
            onOpenSecretBox: {
                router.push(.secretBox)
            },
            onViewAll: {
                router.push(.allKudos)
            },
            selectedLanguage: .vn,
            unreadNotificationCount: 0,
            onSearch: { router.push(.searchSunner) },
            onBell: { router.push(.notifications) },
            onLanguage: {}
        )
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
}
