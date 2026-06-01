// FeatureFlags.swift
// MockProjectAIDD
//
// Compile-time feature flags. Flip these to toggle UI sections / data sources in tests
// (e.g. TC_IOS_HOME_GUI_005 — hide Kudos when unavailable).

import Foundation

enum FeatureFlags {
    /// Drives visibility of the Home Kudos section.
    static let isKudosAvailable: Bool = true

    /// When true (demo mode), Home awards load from bundled mock data instead of the live
    /// Supabase REST API. Flip to false once the Supabase backend is wired and running.
    static let useMockAwards: Bool = true

    /// When true (demo mode), the Send/Write Kudo screen uses bundled mock recipients,
    /// hashtags and current user, and simulates submit success instead of calling KudoService.
    /// Now false: live KudoService.sendKudo + UserService.searchSunners + listHashtags.
    static let useMockKudoData: Bool = false

    /// When true (demo mode), the Notifications screen loads bundled mock notifications
    /// instead of calling NotificationService. Flip to false once the backend is wired.
    static let useMockNotifications: Bool = true

    // MARK: - SAA 2025 countdown target (Asia/Saigon)
    //
    // Real event date is 2025-12-26. The demo target below is set forward so the countdown
    // stays in an active "Coming soon" state during live-coding. Flip these back to
    // year=2025, month=12, day=26 when leaving demo mode.
    static let eventYear: Int = 2026
    static let eventMonth: Int = 6
    static let eventDay: Int = 28
}
