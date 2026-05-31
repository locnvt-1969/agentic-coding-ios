// SendKudoMockData.swift
// MockProjectAIDD
//
// Bundled mock data for the Send/Write Kudo screen used while FeatureFlags.useMockKudoData
// is true. Content sourced from the Figma screens (names, departments, hashtags).
// Replace with live KudoService/UserService calls once the Kudos backend is wired.

import Foundation

enum SendKudoMockData {

    /// Id treated as the signed-in user — used to block sending a kudo to oneself (spec B.2).
    /// Included as the first recipient row so the self-send guard is demonstrable.
    static let currentUserId = "u-self"

    static let recipients: [User] = [
        User(id: currentUserId, name: "Bạn (chính mình)", departmentName: "CECV1"),
        User(id: "u1", name: "Dương Huỳnh Xuân Nhật", departmentName: "CECV1"),
        User(id: "u2", name: "Dương Huỳnh Xuân Nhân", departmentName: "CECV1"),
        User(id: "u3", name: "Huỳnh Dương Xuân", departmentName: "CECV10"),
        User(id: "u4", name: "Nguyễn Văn An", departmentName: "OPD"),
        User(id: "u5", name: "Trần Thị Bình", departmentName: "Infra")
    ]

    static let hashtags: [Hashtag] = [
        "#Dedicated", "#Inspiring", "#High-performing", "#BE PROFESSIONAL",
        "#BE OPTIMISTIC", "#BE A TEAM", "#THINK OUTSIDE THE BOX", "#GET RISKY",
        "#GO FAST", "#WASSHOI"
    ].enumerated().map { Hashtag(id: "h\($0.offset)", name: $0.element, group: nil) }
}
