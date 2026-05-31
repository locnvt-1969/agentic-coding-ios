// ProfileDTO.swift
// MockProjectAIDD
//
// Decode layer for the `get_profile(p_id)` Supabase RPC (returns one composed JSON).
// Decoded with `.convertFromSnakeCase` (see SupabaseRESTClient), then mapped to the
// domain `User` + `ProfileStatsData`. Consumed when UserService is wired (P5).

import Foundation

struct ProfileDTO: Decodable {
    let id: String
    let fullName: String
    let avatarUrl: String?
    let departmentName: String?
    let role: String?
    let heroLabel: String?
    let valueIconIds: [String]
    let stats: Stats

    struct Stats: Decodable {
        let kudosReceived: Int
        let kudosSent: Int
        let heartsReceived: Int
        let secretBoxOpened: Int
        let secretBoxUnopened: Int
    }

    /// Domain user (Hero tier → `level`, DB icon slugs → `SunValueIcon`).
    /// `awardTypes` is intentionally left default ([]) — awards are fetched separately
    /// via AwardService, not part of the get_profile payload.
    func toUser() -> User {
        User(
            id: id,
            name: fullName,
            avatarURL: avatarUrl.flatMap { URL(string: $0) },
            departmentName: departmentName,
            role: role,
            level: heroLabel,
            collectedValueIcons: valueIconIds.compactMap(SunValueIcon.init(dbId:))
        )
    }

    func toStats() -> ProfileStatsData {
        ProfileStatsData(
            kudosReceived: stats.kudosReceived,
            kudosSent: stats.kudosSent,
            heartsReceived: stats.heartsReceived,
            secretBoxOpened: stats.secretBoxOpened,
            secretBoxUnopened: stats.secretBoxUnopened
        )
    }
}
