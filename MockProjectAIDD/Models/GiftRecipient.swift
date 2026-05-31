// GiftRecipient.swift
// MockProjectAIDD
//
// A Sunner who received a physical/digital reward — row in the
// "10 SUNNER NHẬN QUÀ MỚI NHẤT" list (design D.3.2).

import Foundation

struct GiftRecipient: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let avatarURL: String?   // nil → fall back to the SampleAvatar asset
    let rewardText: String   // e.g. "Nhận được 1 áo phông SAA"

    static let sample = GiftRecipient(
        id: "g1",
        name: "Huỳnh Dương Xuân",
        avatarURL: nil,
        rewardText: "Nhận được 1 áo phông SAA"
    )
}
