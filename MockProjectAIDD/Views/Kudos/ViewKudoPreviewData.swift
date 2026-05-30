// ViewKudoPreviewData.swift
// MockProjectAIDD
//
// Static Kudo fixtures used exclusively by ViewKudoView previews.

import Foundation

// MARK: - Preview fixtures

extension Kudo {
    static let previewNamed = Kudo(
        id: "kudo-preview-named",
        sender: User(
            id: "u1",
            name: "Huỳnh Dương Xuân",
            departmentName: "CEVC10"
        ),
        recipients: [
            User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")
        ],
        message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất nhiều cho team, để luôn nhắc mình luôn phải nỗ lực hơn nữa trong công việc. <3 và cuộc sống",
        hashtags: [
            Hashtag(id: "h1", name: "#Dedicated", group: nil),
            Hashtag(id: "h2", name: "#Inspiring", group: nil)
        ],
        isAnonymous: false,
        createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
        reactionCount: 10,
        comments: [
            KudoComment(
                id: "c1",
                author: User(id: "u3", name: "Nguyễn Hà", departmentName: "Engineering"),
                text: "Congrats! Well deserved!",
                createdAt: ISO8601DateFormatter().date(from: "2025-10-30T11:00:00Z") ?? Date()
            )
        ],
        isHighlighted: true
    )

    static let previewAnonymous = Kudo(
        id: "kudo-preview-anon",
        sender: nil,
        recipients: [
            User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")
        ],
        message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất nhiều cho team, để luôn nhắc mình luôn phải nỗ lực hơn nữa trong công việc. <3 và cuộc sống",
        hashtags: [
            Hashtag(id: "h1", name: "#Dedicated", group: nil),
            Hashtag(id: "h2", name: "#Inspiring", group: nil)
        ],
        isAnonymous: true,
        createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
        reactionCount: 10,
        comments: [],
        isHighlighted: true
    )
}
