// HomeViewModel.swift
// MockProjectAIDD
//
// Owns all Home screen state. Wires CountdownTimer and AwardsService; navigation via AppRouter.
// Injected services default to shared singletons; pass alternates in tests.

import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {

    // MARK: - State

    var awardsState: AwardsLoadState = .idle
    var unreadNotificationCount: Int = 3
    var countdown: CountdownValue = .placeholder
    var isLanguageSheetPresented: Bool = false

    var isKudosAvailable: Bool { FeatureFlags.isKudosAvailable }

    // Language persisted via UserDefaults
    var selectedLanguage: AppLanguage {
        get {
            let raw = UserDefaults.standard.string(forKey: "selectedLanguageCode") ?? AppLanguage.vn.rawValue
            return AppLanguage(rawValue: raw) ?? .vn
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "selectedLanguageCode")
        }
    }

    // MARK: - Services

    private let awardsService: AwardsService
    private let countdownTimer: CountdownTimer

    // MARK: - Private

    private var isFabInFlight = false
    private var countdownTickTask: Task<Void, Never>?
    private var awardsLoadTask: Task<Void, Never>?
    private var fabResetTask: Task<Void, Never>?

    // MARK: - Init

    init(
        awardsService: AwardsService? = nil,
        countdownTimer: CountdownTimer? = nil
    ) {
        // Default to shared singletons; callers can inject alternates for testing.
        // CountdownTimer is @MainActor so it can only be created here (on MainActor).
        self.awardsService = awardsService ?? AwardsService.shared
        self.countdownTimer = countdownTimer ?? CountdownTimer()
    }

    // MARK: - Lifecycle

    func onAppear() {
        countdownTimer.start()
        syncCountdown()
        startCountdownSync()
        awardsLoadTask = Task { await loadAwards() }
    }

    func onDisappear() {
        countdownTimer.stop()
        countdownTickTask?.cancel()
        countdownTickTask = nil
        awardsLoadTask?.cancel()
        awardsLoadTask = nil
        fabResetTask?.cancel()
        fabResetTask = nil
    }

    // MARK: - Countdown sync

    private func syncCountdown() {
        countdown = CountdownValue(
            days: countdownTimer.current.days,
            hours: countdownTimer.current.hours,
            minutes: countdownTimer.current.minutes,
            comingSoonVisible: countdownTimer.comingSoonVisible,
            eventEnded: countdownTimer.eventEnded
        )
    }

    private func startCountdownSync() {
        countdownTickTask?.cancel()
        countdownTickTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                guard !Task.isCancelled else { return }
                syncCountdown()
            }
        }
    }

    // MARK: - Awards

    func loadAwards() async {
        // Idempotency guard — prevents racing retry tap with the initial onAppear fetch.
        guard awardsState != .loading else { return }
        awardsState = .loading
        do {
            let items: [AwardItem]
            if FeatureFlags.useMockAwards {
                // Demo mode: serve bundled mock data after a brief delay so the loading
                // state is visible (TC_IOS_HOME_GUI_002). The live API path and the
                // error/retry flow (TC_IOS_HOME_GUI_004 / FUN_003) live in else/catch.
                try await Task.sleep(nanoseconds: 400_000_000)
                items = HomeViewMockData.awards
            } else {
                items = try await awardsService.fetchAwards()
            }
            awardsState = items.isEmpty ? .empty : .loaded(items)
        } catch {
            awardsState = .error(error.localizedDescription)
        }
    }

    func retryAwards() {
        awardsLoadTask?.cancel()
        awardsLoadTask = Task { await loadAwards() }
    }

    // MARK: - Language

    func languageTapped() {
        isLanguageSheetPresented = true
    }

    func selectLanguage(_ lang: AppLanguage) {
        selectedLanguage = lang
        isLanguageSheetPresented = false
    }

    // MARK: - Navigation (push real destinations via AppRouter)

    func searchTapped(router: AppRouter) { router.push(.searchSunner) }                       // TC_IOS_HOME_FUN_020
    func bellTapped(router: AppRouter) { router.push(.notifications) }                         // TC_IOS_HOME_FUN_006
    func aboutAwardTapped(router: AppRouter) { router.push(.awardDetail(type: .topTalent)) }   // TC_IOS_HOME_FUN_007
    func aboutKudosTapped(router: AppRouter) { router.push(.kudosBoard) }                      // TC_IOS_HOME_FUN_008
    func kudosDetailTapped(router: AppRouter) { router.push(.kudosBoard) }                     // TC_IOS_HOME_FUN_011
    func fabSKudosTapped(router: AppRouter) { router.push(.allKudos) }                         // TC_IOS_HOME_FUN_014

    /// Award card "Chi tiết" → Award Detail for that award (TC_IOS_HOME_FUN_004).
    func awardCardTapped(_ id: String, router: AppRouter) {
        router.push(.awardDetail(type: AwardType(awardId: id)))
    }

    /// FAB pencil → Send Kudo form, with double-tap prevention (TC_IOS_HOME_FUN_012 / FUN_013).
    func fabPencilTapped(router: AppRouter) {
        guard !isFabInFlight else { return }
        isFabInFlight = true
        router.push(.sendKudo)
        fabResetTask?.cancel()
        fabResetTask = Task {
            try? await Task.sleep(nanoseconds: 200_000_000)
            isFabInFlight = false
        }
    }
}
