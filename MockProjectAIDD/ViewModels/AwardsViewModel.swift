// AwardsViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class AwardsViewModel {
    var award: Award?
    var isLoading = false
    var errorMessage: String?

    func load(type: AwardType) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            award = try await AwardService.shared.awardDetail(type: type)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
