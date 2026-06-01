// ProfileViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class ProfileViewModel {
    var user: User?
    var stats: ProfileStatsData = .zero
    var kudos: [Kudo] = []
    /// Lifetime received/sent totals (from profile stats), shown on the kudos filter labels.
    var kudosReceivedCount = 0
    var kudosSentCount = 0
    var isLoading = false
    var errorMessage: String?

    /// Pass nil userId for the current (self) profile.
    func load(userId: String?) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            let loaded: User
            if let userId {
                loaded = try await UserService.shared.fetchUser(id: userId)
            } else {
                loaded = try await UserService.shared.fetchCurrentUser()
            }
            user = loaded
            stats = try await UserService.shared.fetchProfileStats(userId: userId)
            kudosReceivedCount = stats.kudosReceived
            kudosSentCount = stats.kudosSent
            // This user's received kudos (non-fatal: a failure still renders header + stats).
            kudos = (try? await KudoService.shared.listReceivedKudos(userId: loaded.id)) ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
