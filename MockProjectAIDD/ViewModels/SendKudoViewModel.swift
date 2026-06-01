// SendKudoViewModel.swift
// MockProjectAIDD
//
// Owns Send/Write Kudo form state. Uses mock data + simulated submit while
// FeatureFlags.useMockKudoData is true; real KudoService/UserService path kept behind it.

import Observation
import SwiftUI

@MainActor
@Observable
final class SendKudoViewModel {
    // Form fields
    var selectedRecipient: User?        // single recipient per kudo (DB: recipient_id)
    var title: String = ""              // Danh hiệu — becomes the kudo title
    var message: String = ""
    var selectedHashtags: [Hashtag] = []
    var isAnonymous: Bool = false

    // Dropdown option sources
    var availableRecipients: [User] = []
    var availableHashtags: [Hashtag] = []

    /// Inline validation / guard message shown on the form (nil = none).
    var validationError: String?
    var didSend = false
    var isLoading = false
    var errorMessage: String?

    private var isInFlight = false

    /// Signed-in user id — blocks self-send (spec B.2). Live path uses the authenticated user.
    /// `nil` when not authenticated → selectRecipient surfaces a login prompt (no silent bypass).
    private var currentUserId: String? {
        FeatureFlags.useMockKudoData ? SendKudoMockData.currentUserId : AuthService.shared.currentUserId
    }

    // MARK: - Load options

    func loadOptions() async {
        if FeatureFlags.useMockKudoData {
            availableHashtags = SendKudoMockData.hashtags
            availableRecipients = SendKudoMockData.recipients
            return
        }
        do {
            availableHashtags = try await KudoService.shared.listHashtags()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func searchRecipients(query: String) async {
        if FeatureFlags.useMockKudoData {
            let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            availableRecipients = q.isEmpty
                ? SendKudoMockData.recipients
                : SendKudoMockData.recipients.filter {
                    $0.name.lowercased().contains(q) || ($0.departmentName ?? "").lowercased().contains(q)
                }
            return
        }
        do {
            availableRecipients = try await UserService.shared.searchSunners(query: query)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Field mutations (centralised, with guards)

    /// Selects the recipient (single per kudo). Blocks self-send (spec B.2); replaces any prior choice.
    func selectRecipient(_ user: User) {
        guard let me = currentUserId else {
            validationError = "Bạn cần đăng nhập để gửi Kudos."
            return
        }
        guard user.id != me else {
            validationError = "Không thể gửi Kudo cho chính mình."
            return
        }
        selectedRecipient = user
        validationError = nil
    }

    /// Adds a hashtag. Enforces the 5-tag maximum (spec E) and dedup.
    func addHashtag(_ hashtag: Hashtag) {
        guard selectedHashtags.count < 5 else {
            validationError = "Tối đa 5 hashtag."
            return
        }
        guard !selectedHashtags.contains(where: { $0.id == hashtag.id }) else { return }
        selectedHashtags.append(hashtag)
        validationError = nil
    }

    func removeHashtag(_ hashtag: Hashtag) {
        selectedHashtags.removeAll { $0.id == hashtag.id }
    }

    // MARK: - Validation (spec I + TC_WRITE_FUN_002)

    /// True when Recipient + Title + Message + ≥1 Hashtag are all present and valid.
    private func validate() -> Bool {
        let titleTrimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let messageTrimmed = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if selectedRecipient == nil || titleTrimmed.isEmpty || messageTrimmed.isEmpty || selectedHashtags.isEmpty {
            validationError = "Bạn cần điền đủ Người nhận, Danh hiệu, Lời nhắn và Hashtag để gửi Kudos!"
            return false
        }
        if titleTrimmed.count > 100 {
            validationError = "Danh hiệu tối đa 100 ký tự."
            return false
        }
        validationError = nil
        return true
    }

    // MARK: - Submit

    func submit() async {
        // isInFlight de-dupes rapid double-taps: the first call sets it before the awaited
        // submit suspends, so a second tap returns early — no duplicate send.
        guard !isInFlight else { return }
        guard validate() else { return }     // TC_WRITE_FUN_002: invalid → no send
        didSend = false
        isInFlight = true
        isLoading = true
        defer {
            isInFlight = false
            isLoading = false
        }

        if FeatureFlags.useMockKudoData {
            // Simulate a successful send (real API wired later).
            try? await Task.sleep(nanoseconds: 400_000_000)
            didSend = true
            return
        }

        guard let recipient = selectedRecipient else { return }
        let payload = SendKudoPayload(
            recipient: recipient,
            title: title,
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

    /// True when the form holds content worth a cancel-confirmation (spec H).
    var hasUnsavedContent: Bool {
        selectedRecipient != nil
            || !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || !selectedHashtags.isEmpty
    }
}
