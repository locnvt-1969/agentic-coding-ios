// SecretBoxViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class SecretBoxViewModel {
    var box: SecretBox = .sample
    var isLoading = false
    var errorMessage: String?

    private var isInFlight = false

    func load() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            box = try await SecretBoxService.shared.currentBox()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// State machine: closed → opening → standby (with reward).
    func open() async {
        guard !isInFlight, box.state == .closed else { return }
        isInFlight = true
        defer { isInFlight = false }
        box.state = .opening
        do {
            let reward = try await SecretBoxService.shared.openBox()
            box.reward = reward
            box.state = .standby
        } catch {
            errorMessage = error.localizedDescription
            box.state = .closed
        }
    }
}
