// ToastCenter.swift
// MockProjectAIDD
//
// Ephemeral toast queue. Used to surface "Navigate to X" feedback for
// destination CTAs (Search, Notifications, About, Award/Kudos Detail, WriteKudo,
// Kudos Feed, Language modal) until those screens land.

import Foundation
import Observation

@Observable
@MainActor
final class ToastCenter {
    static let shared = ToastCenter()
    private init() {}

    var message: String?
    private var dismissTask: Task<Void, Never>?

    func show(_ text: String, duration: TimeInterval = 1.6) {
        message = text
        dismissTask?.cancel()
        dismissTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
            guard !Task.isCancelled else { return }
            self?.message = nil
        }
    }
}
