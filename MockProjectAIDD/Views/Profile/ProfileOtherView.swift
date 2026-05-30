// ProfileOtherView.swift
// MockProjectAIDD
//
// Root composer for "Profile người khác" (other-user profile) screen — phase 09.
// Reuses: ProfileHeader, ProfileBadges, ProfileKudosSection (via thin composition).
// New: ProfileSendKudoButton replaces the edit pencil; no stats card shown.
// Presentational only — no service calls, no ViewModel ownership.
//
// Public contract:
//   ProfileOtherView(user:awards:onSendKudo:onOpenAward:
//                    kudos:kudosReceivedCount:onCopyKudoLink:onViewKudoDetail:)

import SwiftUI

struct ProfileOtherView: View {
    let user: User
    let awards: [Award] // Reserved for phase-19 symmetry; badges render from user.awardTypes.
    var onSendKudo: () -> Void = {}
    var onOpenAward: (AwardType) -> Void = { _ in }

    // Kudos — other-user profile shows received kudos only (read-only filter)
    var kudos: [Kudo] = []
    var kudosReceivedCount: Int = 0
    var onCopyKudoLink: ((Kudo) -> Void)? = nil
    var onViewKudoDetail: ((Kudo) -> Void)? = nil

    // Internally fixed to .received — other-user view is read-only
    @State private var kudosFilter: KudosFilterOption = .received

    var body: some View {
        ZStack(alignment: .top) {
            Color.profileDark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Header — keyvisual BG + avatar + name (reused as-is)
                    ProfileHeader(user: user)

                    // 2. Badge collection (reused as-is)
                    ProfileBadges(
                        awardTypes: user.awardTypes,
                        onOpenAward: onOpenAward
                    )
                    .padding(.horizontal, 57)
                    .padding(.top, 24)

                    // 3. Send Kudo CTA (NEW — replaces edit button / no stats card)
                    ProfileSendKudoButton(
                        recipientName: user.name,
                        onTap: onSendKudo
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    // 4. Kudos section (reused — filter locked to .received)
                    ProfileKudosSection(
                        kudos: kudos,
                        receivedCount: kudosReceivedCount,
                        sentCount: 0,
                        selectedFilter: $kudosFilter,
                        isFilterLocked: true,
                        onCopyLink: onCopyKudoLink,
                        onViewDetail: onViewKudoDetail
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("ProfileOtherView - sample data") {
    let sampleUser = User(
        id: "u2",
        name: "Huỳnh Dương Xuân Nhật",
        avatarURL: nil,
        departmentName: "CEVC3",
        role: "Engineer",
        level: "Rising Hero",
        awardTypes: [.mvp, .topTalent]
    )

    let sampleKudo = Kudo(
        id: "k1",
        sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
        recipients: [sampleUser],
        message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất...",
        hashtags: [
            Hashtag(id: "h1", name: "#Dedicated", group: nil),
            Hashtag(id: "h2", name: "#Inspring", group: nil)
        ],
        isAnonymous: false,
        createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
        reactionCount: 1000,
        isHighlighted: true
    )

    ProfileOtherView(
        user: sampleUser,
        awards: [],
        onSendKudo: {},
        onOpenAward: { _ in },
        kudos: [sampleKudo, sampleKudo, sampleKudo],
        kudosReceivedCount: 5,
        onCopyKudoLink: { _ in },
        onViewKudoDetail: { _ in }
    )
}
