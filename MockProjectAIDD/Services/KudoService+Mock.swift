// KudoService+Mock.swift
// MockProjectAIDD
//
// Local mock data for the Kudos board. TEMPORARY: delete this file and replace
// the KudoService method bodies with Supabase calls when the backend is wired.
// Kept as an extension so the swap is surgical and KudoService.swift stays lean.

import Foundation

extension KudoService {

    // MARK: - Hashtags (filter dropdown)

    static let mockHashtags: [Hashtag] = [
        Hashtag(id: "h1", name: "#Dedicated", group: nil),
        Hashtag(id: "h2", name: "#Inspiring", group: nil),
        Hashtag(id: "h3", name: "#TeamPlayer", group: nil),
        Hashtag(id: "h4", name: "#Creative", group: nil),
        Hashtag(id: "h5", name: "#Leadership", group: nil),
        Hashtag(id: "h6", name: "#Supportive", group: nil)
    ]

    // MARK: - Spotlight + personal stats

    static let mockSpotlightTotal = 388

    static let mockStats = KudosStats.sample

    // MARK: - Top 10 gift recipients

    static let mockGiftRecipients: [GiftRecipient] = [
        GiftRecipient(id: "g1", name: "Huỳnh Dương Xuân", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g2", name: "Dương Xuân Huỳnh", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g3", name: "Nguyễn Bá Chức", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g4", name: "Mai Phương Thúy", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g5", name: "Lê Kiều Trang", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g6", name: "Trần Văn An", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g7", name: "Phạm Thu Hà", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g8", name: "Lê Quốc Bảo", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g9", name: "Đỗ Minh Châu", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g10", name: "Hoàng Văn Nam", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA")
    ]

    // MARK: - Kudos feed

    /// Helper: builds a fixed local date so previews/mocks are deterministic.
    private static func date(_ y: Int, _ mo: Int, _ d: Int, _ h: Int, _ mi: Int) -> Date {
        var c = DateComponents()
        c.year = y; c.month = mo; c.day = d; c.hour = h; c.minute = mi
        return Calendar(identifier: .gregorian).date(from: c) ?? Date(timeIntervalSince1970: 0)
    }

    /// Top 5 (reactionCount desc) are highlighted → drive the carousel; rest fill the feed.
    static let mockKudos: [Kudo] = [
        Kudo(
            id: "k1",
            sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC2"),
            recipients: [User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC2")],
            message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất nhiều cho cả team!",
            hashtags: [mockHashtags[0], mockHashtags[1]],
            isAnonymous: false,
            createdAt: date(2025, 10, 30, 10, 0),
            reactionCount: 1000,
            isHighlighted: true
        ),
        Kudo(
            id: "k2",
            sender: nil,
            recipients: [User(id: "u3", name: "Nguyễn Bá Chức", departmentName: "OPD")],
            message: "Cảm ơn em đã luôn cố gắng và nỗ lực không ngừng nghỉ!",
            hashtags: [mockHashtags[1]],
            isAnonymous: true,
            createdAt: date(2025, 10, 29, 14, 20),
            reactionCount: 850,
            isHighlighted: true
        ),
        Kudo(
            id: "k3",
            sender: User(id: "u4", name: "Mai Phương Thúy", departmentName: "OPD"),
            recipients: [User(id: "u5", name: "Lê Kiều Trang", departmentName: "Infra")],
            message: "Cảm ơn chị vì sự hỗ trợ tận tình trong dự án vừa rồi!",
            hashtags: [mockHashtags[0], mockHashtags[2]],
            isAnonymous: false,
            createdAt: date(2025, 10, 28, 9, 15),
            reactionCount: 720,
            isHighlighted: true
        ),
        Kudo(
            id: "k4",
            sender: User(id: "u6", name: "Trần Văn An", departmentName: "CEVC3"),
            recipients: [User(id: "u7", name: "Phạm Thu Hà", departmentName: "CEVC3")],
            message: "Cảm ơn bạn đã hỗ trợ mình hoàn thành sprint đúng hạn!",
            hashtags: [mockHashtags[2], mockHashtags[4]],
            isAnonymous: false,
            createdAt: date(2025, 10, 27, 16, 45),
            reactionCount: 540,
            isHighlighted: true
        ),
        Kudo(
            id: "k5",
            sender: User(id: "u8", name: "Lê Quốc Bảo", departmentName: "Infra"),
            recipients: [User(id: "u9", name: "Đỗ Minh Châu", departmentName: "CEVC1")],
            message: "Cảm ơn anh vì những review tận tâm và chi tiết!",
            hashtags: [mockHashtags[3], mockHashtags[5]],
            isAnonymous: false,
            createdAt: date(2025, 10, 26, 11, 30),
            reactionCount: 430,
            isHighlighted: true
        ),
        Kudo(
            id: "k6",
            sender: User(id: "u10", name: "Nguyễn Thị Mai", departmentName: "CEVC4"),
            recipients: [User(id: "u11", name: "Hoàng Văn Nam", departmentName: "CEVC4")],
            message: "Cảm ơn team đã đồng hành suốt thời gian qua!",
            hashtags: [mockHashtags[2]],
            isAnonymous: false,
            createdAt: date(2025, 10, 25, 8, 0),
            reactionCount: 120,
            isHighlighted: false
        ),
        Kudo(
            id: "k7",
            sender: nil,
            recipients: [User(id: "u12", name: "Vũ Hồng Sơn", departmentName: "OPD")],
            message: "Cảm ơn bạn vì tinh thần trách nhiệm cao trong công việc!",
            hashtags: [mockHashtags[0]],
            isAnonymous: true,
            createdAt: date(2025, 10, 24, 13, 10),
            reactionCount: 88,
            isHighlighted: false
        ),
        Kudo(
            id: "k8",
            sender: User(id: "u13", name: "Phan Khánh Linh", departmentName: "CEVC2"),
            recipients: [User(id: "u14", name: "Bùi Tiến Dũng", departmentName: "Infra")],
            message: "Cảm ơn vì luôn sẵn sàng giúp đỡ mọi người!",
            hashtags: [mockHashtags[5]],
            isAnonymous: false,
            createdAt: date(2025, 10, 23, 17, 25),
            reactionCount: 64,
            isHighlighted: false
        )
    ]
}
