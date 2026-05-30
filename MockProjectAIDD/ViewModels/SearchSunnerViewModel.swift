// SearchSunnerViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class SearchSunnerViewModel {
    var query: String = ""
    var results: [User] = []
    var isSearching = false
    var errorMessage: String?

    private var searchTask: Task<Void, Never>?

    /// Debounced search — cancels the prior in-flight query when the text changes.
    func updateQuery(_ text: String) {
        query = text
        searchTask?.cancel()
        let trimmed = text.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            results = []
            isSearching = false
            return
        }
        searchTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(300))
            guard let self, !Task.isCancelled else { return }
            await self.performSearch(trimmed)
        }
    }

    private func performSearch(_ text: String) async {
        isSearching = true
        defer { isSearching = false }
        do {
            results = try await UserService.shared.searchSunners(query: text)
        } catch {
            guard !Task.isCancelled else { return }
            errorMessage = error.localizedDescription
        }
    }
}
