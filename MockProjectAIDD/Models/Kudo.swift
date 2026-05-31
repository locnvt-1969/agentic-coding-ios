// Kudo.swift
// MockProjectAIDD

import Foundation

struct Kudo: Identifiable, Hashable, Codable {
    let id: String
    /// Optional self-set title (danh hiệu) shown as the kudo's heading.
    let title: String?
    /// Raw sender. NEVER read directly in the view layer — use `resolvedSender`,
    /// which enforces anonymity. Kept private so the invariant is unbypassable.
    private let sender: User?
    let recipients: [User]
    let message: String
    let hashtags: [Hashtag]
    let isAnonymous: Bool
    let createdAt: Date
    let reactionCount: Int
    let comments: [KudoComment]
    let isHighlighted: Bool
    /// Flagged by moderation as spam — drives the "Spam" badge on the kudo card.
    let isSpam: Bool

    init(
        id: String,
        title: String? = nil,
        sender: User?,
        recipients: [User],
        message: String,
        hashtags: [Hashtag] = [],
        isAnonymous: Bool = false,
        createdAt: Date = Date(timeIntervalSince1970: 0),
        reactionCount: Int = 0,
        comments: [KudoComment] = [],
        isHighlighted: Bool = false,
        isSpam: Bool = false
    ) {
        self.id = id
        self.title = title
        self.sender = sender
        self.recipients = recipients
        self.message = message
        self.hashtags = hashtags
        self.isAnonymous = isAnonymous
        self.createdAt = createdAt
        self.reactionCount = reactionCount
        self.comments = comments
        self.isHighlighted = isHighlighted
        self.isSpam = isSpam
    }

    /// Decodes with the anonymity invariant enforced: an anonymous kudo never
    /// retains a sender, regardless of what the backend payload contains.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        recipients = try c.decode([User].self, forKey: .recipients)
        message = try c.decode(String.self, forKey: .message)
        hashtags = try c.decodeIfPresent([Hashtag].self, forKey: .hashtags) ?? []
        isAnonymous = try c.decodeIfPresent(Bool.self, forKey: .isAnonymous) ?? false
        createdAt = try c.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date(timeIntervalSince1970: 0)
        reactionCount = try c.decodeIfPresent(Int.self, forKey: .reactionCount) ?? 0
        comments = try c.decodeIfPresent([KudoComment].self, forKey: .comments) ?? []
        isHighlighted = try c.decodeIfPresent(Bool.self, forKey: .isHighlighted) ?? false
        isSpam = try c.decodeIfPresent(Bool.self, forKey: .isSpam) ?? false
        let decodedSender = try c.decodeIfPresent(User.self, forKey: .sender)
        sender = isAnonymous ? nil : decodedSender
    }

    /// The only safe way to read the sender. Returns nil for anonymous kudos.
    var resolvedSender: User? { isAnonymous ? nil : sender }

    static let sample = Kudo(
        id: "k1",
        sender: .sample,
        recipients: [.sample],
        message: "Thank you for the great teamwork!",
        hashtags: [.sample]
    )
}
