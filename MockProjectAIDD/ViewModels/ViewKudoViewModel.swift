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

    private var isInFlight = false
    private var isReactionInFlight = false

    /// Sender display name, respecting anonymity (never exposes a hidden sender).
    var senderDisplayName: String {
        guard let kudo else { return "" }
        return kudo.resolvedSender?.name ?? "Ẩn danh"
    }

    func load(id: String) async {
        guard !isInFlight else { return }
        isInFlight = true
        isLoading = true
        errorMessage = nil
        defer {
            isInFlight = false
            isLoading = false
        }
        do {
            kudo = try await KudoService.shared.viewKudo(id: id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Toggle the current user's ❤️ on the open kudo. Optimistic with rollback on failure.
    /// Guarded so a rapid double-tap cannot fire overlapping react/unreact calls.
    func toggleReaction() {
        guard !isReactionInFlight, var current = kudo else { return }
        isReactionInFlight = true
        let wasReacted = current.hasReacted
        current.hasReacted = !wasReacted
        current.reactionCount += wasReacted ? -1 : 1
        kudo = current
        let kudoId = current.id
        Task {
            defer { isReactionInFlight = false }
            do {
                if wasReacted {
                    try await KudoService.shared.unreact(kudoId: kudoId)
                } else {
                    try await KudoService.shared.react(kudoId: kudoId)
                }
            } catch {
                guard var revert = kudo, revert.id == kudoId else { return }
                revert.hasReacted = wasReacted
                revert.reactionCount += wasReacted ? 1 : -1
                kudo = revert
                errorMessage = error.localizedDescription
            }
        }
    }
}
