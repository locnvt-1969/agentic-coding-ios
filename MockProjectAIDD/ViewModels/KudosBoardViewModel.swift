// KudosBoardViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class KudosBoardViewModel {
    var kudos: [Kudo] = []
    var hashtags: [Hashtag] = []
    var departments: [Department] = []
    var stats: KudosStats?
    var giftRecipients: [GiftRecipient] = []
    var spotlightTotal = 0
    var filter = KudoFilter()
    var isLoading = false
    var errorMessage: String?

    private var isInFlight = false
    // Kudo ids with an in-flight react/unreact — blocks double-tap on the same card
    // while still allowing concurrent reactions on different cards.
    private var reactionsInFlight: Set<String> = []

    func load() async {
        guard !isInFlight else { return }
        isInFlight = true
        isLoading = true
        errorMessage = nil
        defer {
            isInFlight = false
            isLoading = false
        }
        do {
            async let feed = KudoService.shared.listKudos(filter: filter)
            async let tags = KudoService.shared.listHashtags()
            async let depts = UserService.shared.listDepartments()
            async let personalStats = KudoService.shared.fetchPersonalStats()
            async let recipients = KudoService.shared.listGiftRecipients()
            async let spotlight = KudoService.shared.spotlightTotalKudos()
            // Await all into locals first so a partial failure never leaves a mix
            // of fresh + stale state on screen — commit only once everything succeeds.
            let (loadedKudos, loadedTags, loadedDepts, loadedStats, loadedRecipients, loadedSpotlight) =
                try await (feed, tags, depts, personalStats, recipients, spotlight)
            kudos = loadedKudos
            hashtags = loadedTags
            departments = loadedDepts
            stats = loadedStats
            giftRecipients = loadedRecipients
            spotlightTotal = loadedSpotlight
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func apply(filter: KudoFilter) async {
        guard !isInFlight else { return }
        isInFlight = true
        isLoading = true
        errorMessage = nil
        defer {
            isInFlight = false
            isLoading = false
        }
        self.filter = filter
        do {
            kudos = try await KudoService.shared.listKudos(filter: filter)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    /// Toggle the current user's ❤️ on a kudo. Optimistic: the heart flips and the
    /// count adjusts immediately, then we persist; on failure we roll the card back.
    /// Guarded per kudo id so a rapid double-tap can't fire overlapping calls.
    func toggleReaction(_ kudo: Kudo) {
        let kudoId = kudo.id
        guard !reactionsInFlight.contains(kudoId),
              let idx = kudos.firstIndex(where: { $0.id == kudoId }) else { return }
        reactionsInFlight.insert(kudoId)
        let wasReacted = kudos[idx].hasReacted
        kudos[idx].hasReacted = !wasReacted
        kudos[idx].reactionCount += wasReacted ? -1 : 1
        Task {
            defer { reactionsInFlight.remove(kudoId) }
            do {
                if wasReacted {
                    try await KudoService.shared.unreact(kudoId: kudoId)
                } else {
                    try await KudoService.shared.react(kudoId: kudoId)
                }
            } catch {
                // Roll back the optimistic change if the server rejected it. If load()
                // replaced the array meanwhile, the guard drops the rollback — intentional,
                // the reload is ground truth.
                guard let revertIdx = kudos.firstIndex(where: { $0.id == kudoId }) else { return }
                kudos[revertIdx].hasReacted = wasReacted
                kudos[revertIdx].reactionCount += wasReacted ? 1 : -1
                errorMessage = error.localizedDescription
            }
        }
    }
}
