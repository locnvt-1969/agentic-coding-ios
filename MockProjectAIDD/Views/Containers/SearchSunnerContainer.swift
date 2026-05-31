// SearchSunnerContainer.swift
// MockProjectAIDD
//
// Container: wires SearchSunnerViewModel → SearchSunnerView.
// Phase-19 integration.

import SwiftUI

struct SearchSunnerContainer: View {
    @State private var vm = SearchSunnerViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        // No initial load — results are query-driven via onQueryChange.
        SearchSunnerView(
            query: vm.query,
            isSearching: vm.isSearching,
            results: vm.results,
            onQueryChange: { text in
                vm.updateQuery(text)
            },
            onSelect: { user in
                router.push(.profileOther(userId: user.id))
            }
        )
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
