// ProfileViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class ProfileViewModel {
    var user: User?
    var awards: [Award] = []
    var kudos: [Kudo] = []
    var kudosReceivedCount = 0
    // TODO: real sent/received split when API lands
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
            awards = try await AwardService.shared.fetchAwards(userId: loaded.id)
            kudos = (try? await KudoService.shared.listAllKudos()) ?? []
            kudosReceivedCount = kudos.count
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
