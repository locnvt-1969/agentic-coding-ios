// ViewKudoViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class ViewKudoViewModel {
    var kudo: Kudo?
    var isLoading = false
    var errorMessage: String?

    /// Sender display name, respecting anonymity (never exposes a hidden sender).
    var senderDisplayName: String {
        guard let kudo else { return "" }
        return kudo.resolvedSender?.name ?? "Ẩn danh"
    }

    func load(id: String) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        do {
            kudo = try await KudoService.shared.viewKudo(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
