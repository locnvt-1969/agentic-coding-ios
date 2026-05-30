// ProfileViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class ProfileViewModel {
    var user: User?
    var awards: [Award] = []
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
            awards = try await AwardService.shared.fetchAwards(userId: loaded.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
