// SendKudoViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class SendKudoViewModel {
    var recipients: [User] = []
    var message: String = ""
    var selectedHashtags: [Hashtag] = []
    var isAnonymous: Bool = false

    var availableRecipients: [User] = []
    var availableHashtags: [Hashtag] = []

    /// Drives the "Lỗi chưa điền hết" validation state on the view.
    var validationError: String?
    var didSend = false
    var isLoading = false
    var errorMessage: String?

    private var isInFlight = false

    func loadOptions() async {
        do {
            availableHashtags = try await KudoService.shared.listHashtags()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func searchRecipients(query: String) async {
        do {
            availableRecipients = try await UserService.shared.searchSunners(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Returns true when the form is complete.
    private func validate() -> Bool {
        if recipients.isEmpty || message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationError = "Vui lòng điền đầy đủ thông tin."
            return false
        }
        validationError = nil
        return true
    }

    func submit() async {
        guard !isInFlight else { return }
        guard validate() else { return }
        isInFlight = true
        isLoading = true
        defer {
            isInFlight = false
            isLoading = false
        }
        let payload = SendKudoPayload(
            recipients: recipients,
            message: message,
            hashtags: selectedHashtags,
            isAnonymous: isAnonymous
        )
        do {
            try await KudoService.shared.sendKudo(payload)
            didSend = true
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
