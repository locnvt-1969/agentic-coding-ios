// CountdownTimer.swift
// MockProjectAIDD
//
// Ticks every second toward the SAA 2025 event date (2025-12-26 00:00 Asia/Saigon).
// Exposes current CountdownValue, comingSoonVisible, and eventEnded flags.

import Foundation
import Observation

@Observable
@MainActor
final class CountdownTimer {

    // MARK: - Public state

    private(set) var current: CountdownValue = .placeholder
    private(set) var comingSoonVisible: Bool = true
    private(set) var eventEnded: Bool = false

    // MARK: - Private

    private var timer: Timer?

    private static let gregorianCalendar: Calendar = {
        var cal = Calendar(identifier: .gregorian)
        if let tz = TimeZone(identifier: "Asia/Saigon") {
            cal.timeZone = tz
        }
        return cal
    }()

    // Countdown target date is sourced from FeatureFlags (Asia/Saigon). The real SAA 2025
    // event date is 2025-12-26; FeatureFlags defaults to a forward demo date so the countdown
    // stays active during live-coding — flip the FeatureFlags constants to change it.
    private static let targetDate: Date = {
        var components = DateComponents()
        components.year = FeatureFlags.eventYear
        components.month = FeatureFlags.eventMonth
        components.day = FeatureFlags.eventDay
        components.hour = 0
        components.minute = 0
        components.second = 0
        components.timeZone = TimeZone(identifier: "Asia/Saigon")
        // Fallback to distantFuture if calendar fails — countdown stays at "Coming soon".
        return gregorianCalendar.date(from: components) ?? Date.distantFuture
    }()

    // MARK: - Lifecycle

    func start() {
        tick()
        // Schedule on .common mode so ticks continue during ScrollView tracking (TC_IOS_HOME_FUN_001).
        let t = Timer(timeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in self?.tick() }
        }
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Tick

    private func tick() {
        let now = Date()
        let target = CountdownTimer.targetDate

        if now >= target {
            comingSoonVisible = false
            eventEnded = true
            current = CountdownValue(days: 0, hours: 0, minutes: 0,
                                     comingSoonVisible: false, eventEnded: true)
            return
        }

        comingSoonVisible = true
        eventEnded = false

        let components = CountdownTimer.gregorianCalendar.dateComponents(
            [.day, .hour, .minute],
            from: now,
            to: target
        )

        let days = max(0, components.day ?? 0)
        let hours = max(0, components.hour ?? 0)
        let minutes = max(0, components.minute ?? 0)

        current = CountdownValue(
            days: days,
            hours: hours,
            minutes: minutes,
            comingSoonVisible: true,
            eventEnded: false
        )
    }
}
