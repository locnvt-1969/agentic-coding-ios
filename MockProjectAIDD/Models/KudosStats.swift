// KudosStats.swift
// MockProjectAIDD
//
// Personal Kudos statistics shown in the ALL KUDOS block (design D.1).

import Foundation

struct KudosStats: Hashable, Codable {
    let kudosReceived: Int         // Số Kudos bạn nhận được
    let kudosSent: Int             // Số Kudos bạn đã gửi
    let heartsReceived: Int        // Số tim bạn nhận được
    let isDoubleBonusActive: Bool  // x2 fire badge beside hearts (admin-configured special day)
    let secretBoxesOpened: Int     // Số Secret Box bạn đã mở
    let secretBoxesUnopened: Int   // Số Secret Box chưa mở

    static let sample = KudosStats(
        kudosReceived: 25,
        kudosSent: 25,
        heartsReceived: 25,
        isDoubleBonusActive: true,
        secretBoxesOpened: 25,
        secretBoxesUnopened: 25
    )
}
