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
}
