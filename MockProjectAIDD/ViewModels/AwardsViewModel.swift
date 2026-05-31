// AwardsViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class AwardsViewModel {
    var award: Award?
    var selectedType: AwardType = .topTalent
    var isLoading = false
    var errorMessage: String?

    /// All award types available in the dropdown switcher.
    let availableTypes: [AwardType] = AwardType.allCases

    func load(type: AwardType) async {
        selectedType = type
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            award = try await AwardService.shared.awardDetail(type: type)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Switch the displayed award when the user picks a type from the dropdown.
    func select(_ type: AwardType) {
        guard type != selectedType else { return }
        Task { await load(type: type) }
    }
}
