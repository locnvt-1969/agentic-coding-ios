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
            kudos = try await feed
            hashtags = try await tags
            departments = try await depts
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
