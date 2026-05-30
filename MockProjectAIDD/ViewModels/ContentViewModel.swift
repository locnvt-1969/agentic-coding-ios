// ContentViewModel.swift
// MockProjectAIDD
//
// Backs the two read-only content screens: Community Standards and Rules (Thể lệ).

import Observation
import SwiftUI

@MainActor
@Observable
final class ContentViewModel {
    var communityStandard: CommunityStandard?
    var rule: Rule?
    var isLoading = false
    var errorMessage: String?

    func loadCommunityStandards() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            communityStandard = try await ContentService.shared.communityStandards()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadRules() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            rule = try await ContentService.shared.rules()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
