// KudoDTO.swift
// MockProjectAIDD
//
// Decode layer for the `list_kudos` Supabase RPC (composed JSON, anonymity already
// enforced server-side: `sender` is null for anonymous kudos). Decoded with
// `.convertFromSnakeCase`, then mapped to the domain `Kudo`.

import Foundation

struct KudoDTO: Decodable {
    let id: String
    let title: String?
    let message: String
    let isAnonymous: Bool
    let isSpam: Bool
    let reactionCount: Int
    let createdAt: String?
    let sender: UserRef?
    let recipient: UserRef?
    let hashtags: [HashtagRef]

    struct UserRef: Decodable {
        let id: String
        let fullName: String
        let departmentName: String?
    }

    struct HashtagRef: Decodable {
        let id: String
        let name: String
    }

    func toKudo() -> Kudo {
        Kudo(
            id: id,
            title: title,
            sender: sender.map { User(id: $0.id, name: $0.fullName, departmentName: $0.departmentName) },
            recipients: recipient.map { [User(id: $0.id, name: $0.fullName, departmentName: $0.departmentName)] } ?? [],
            message: message,
            hashtags: hashtags.map { Hashtag(id: $0.id, name: $0.name, group: nil) },
            isAnonymous: isAnonymous,
            createdAt: Self.parseTimestamp(createdAt),
            reactionCount: reactionCount,
            isSpam: isSpam
        )
    }

    private static let fractionalFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]; return f
    }()
    private static let plainFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter(); f.formatOptions = [.withInternetDateTime]; return f
    }()

    /// Postgres timestamptz JSON → Date (handles optional fractional seconds).
    private static func parseTimestamp(_ value: String?) -> Date {
        guard let value else { return Date(timeIntervalSince1970: 0) }
        return fractionalFormatter.date(from: value)
            ?? plainFormatter.date(from: value)
            ?? Date(timeIntervalSince1970: 0)
    }
}
