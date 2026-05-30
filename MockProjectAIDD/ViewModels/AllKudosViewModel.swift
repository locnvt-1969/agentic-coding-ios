// AllKudosViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class AllKudosViewModel {
    var kudos: [Kudo] = []
    var isLoading = false
    var errorMessage: String?

    private var page = 0
    private var isInFlight = false

    func load() async {
        // Don't reset paging state while a loadMore() is in flight, or its
        // stale page-N results would append into the fresh page-0 list.
        guard !isInFlight else { return }
        page = 0
        kudos = []
        await fetchNextPage()
    }

    func loadMore() async {
        await fetchNextPage()
    }

    private func fetchNextPage() async {
        guard !isInFlight else { return }
        isInFlight = true
        isLoading = true
        defer {
            isInFlight = false
            isLoading = false
        }
        do {
            let next = try await KudoService.shared.listAllKudos(page: page)
            kudos.append(contentsOf: next)
            if !next.isEmpty { page += 1 }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
