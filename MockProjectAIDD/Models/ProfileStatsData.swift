// ProfileStatsData.swift
// MockProjectAIDD
//
// Pure data model for the profile "Thống kê tổng quát" card — no business logic.
// Lives in Models so the service layer can return it (UserService.fetchProfileStats).

import Foundation

struct ProfileStatsData: Hashable, Codable {
    var kudosReceived: Int
    var kudosSent: Int
    var heartsReceived: Int
    var secretBoxOpened: Int
    var secretBoxUnopened: Int

    static let zero = ProfileStatsData(
        kudosReceived: 0,
        kudosSent: 0,
        heartsReceived: 0,
        secretBoxOpened: 0,
        secretBoxUnopened: 0
    )

    static let sample = ProfileStatsData(
        kudosReceived: 5,
        kudosSent: 25,
        heartsReceived: 25,
        secretBoxOpened: 25,
        secretBoxUnopened: 25
    )
}
