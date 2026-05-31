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
    /// Counts on the kudos filter labels = size of the currently-loaded list (design: "Đã gửi (5)" / "Đã nhận (5)").
    /// These are deliberately NOT the lifetime totals — those live on the stats card (`stats.kudosSent` = 25).
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
            // Kudos are non-fatal: a failure here still renders the profile header + stats
            // rather than blanking the whole screen, so it stays a `try?` (not the outer catch).
            kudos = (try? await KudoService.shared.listAllKudos()) ?? []
            kudosReceivedCount = kudos.count
            kudosSentCount = kudos.count
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
