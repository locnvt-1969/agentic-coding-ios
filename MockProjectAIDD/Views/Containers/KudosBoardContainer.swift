// KudosBoardContainer.swift
// MockProjectAIDD
//
// Container: wires KudosBoardViewModel → KudosBoardView.
// Phase-19 integration.

import SwiftUI

struct KudosBoardContainer: View {
    @State private var vm = KudosBoardViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        KudosBoardView(
            kudos: vm.kudos,
            hashtags: vm.hashtags,
            departments: vm.departments,
            onSelectHashtag: { hashtag in
                let filter = KudoFilter(
                    hashtagId: hashtag?.id,
                    departmentId: vm.filter.departmentId
                )
                Task { await vm.apply(filter: filter) }
            },
            onSelectDepartment: { department in
                let filter = KudoFilter(
                    hashtagId: vm.filter.hashtagId,
                    departmentId: department?.id
                )
                Task { await vm.apply(filter: filter) }
            },
            onOpenKudo: { kudo in
                router.push(.viewKudo(id: kudo.id))
            },
            onSendKudo: {
                router.push(.sendKudo)
            }
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
