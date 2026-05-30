// ProfileSelfView.swift
// MockProjectAIDD
//
// Root composer for "Profile bản thân" screen.
// Composes: ProfileHeader + ProfileBadges + ProfileStats + ProfileKudosSection.
// Presentational: data + callbacks as props. No service calls, no ViewModel ownership.
// Public contract (for phase-09 + phase-19):
//   ProfileSelfView(user:awards:onEdit:onOpenAward:kudos:kudosReceivedCount:
//                   kudosSentCount:onOpenSecretBox:onCopyKudoLink:onViewKudoDetail:)
//   — edit button is a ProfileSelfView-only overlay; ProfileHeader stays viewer-agnostic for phase-09 reuse.

import SwiftUI

struct ProfileSelfView: View {
    let user: User
    let awards: [Award]
    var onEdit: () -> Void = {}
    var onOpenAward: (AwardType) -> Void = { _ in }

    // Kudos filter state — owned here, passed as binding into section
    @State private var kudosFilter: KudosFilterOption = .sent

    // Sample kudos for preview — in production wired by ViewModel
    var kudos: [Kudo] = []
    var kudosReceivedCount: Int = 0
    var kudosSentCount: Int = 0
    var onOpenSecretBox: (() -> Void)? = nil
    var onCopyKudoLink: ((Kudo) -> Void)? = nil
    var onViewKudoDetail: ((Kudo) -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Color.profileDark.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // 1. Header (keyvisual + avatar + name)
                    ProfileHeader(user: user)

                    // 2. Badge collection
                    ProfileBadges(
                        awardTypes: user.awardTypes,
                        onOpenAward: onOpenAward
                    )
                    .padding(.horizontal, 57)
                    .padding(.top, 24)

                    // 3. Stats card
                    ProfileStats(
                        stats: buildStats(),
                        onOpenSecretBox: onOpenSecretBox
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 24)

                    // 4. Kudos section
                    ProfileKudosSection(
                        kudos: kudos,
                        receivedCount: kudosReceivedCount,
                        sentCount: kudosSentCount,
                        selectedFilter: $kudosFilter,
                        onCopyLink: onCopyKudoLink,
                        onViewDetail: onViewKudoDetail
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 40)
                    .padding(.bottom, 40)
                }
            }

            // Edit button (pencil icon, top-right)
            VStack {
                HStack {
                    Spacer()
                    Button(action: onEdit) {
                        Image(systemName: "pencil")
                            .font(.system(size: 17, weight: .medium))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                    }
                    .padding(.trailing, 4)
                    .padding(.top, 44) // below status bar
                }
                Spacer()
            }
        }
    }

    // MARK: Helpers

    private func buildStats() -> ProfileStatsData {
        // In production the ViewModel provides these counts.
        // Using zero defaults until wired — no magic numbers invented.
        ProfileStatsData(
            kudosReceived: kudosReceivedCount,
            kudosSent: kudosSentCount,
            heartsReceived: 0,
            secretBoxOpened: 0,
            secretBoxUnopened: 0
        )
    }
}

// MARK: - Preview

#Preview("ProfileSelfView - sample data") {
    @Previewable @State var dummy = false

    let sampleUser = User(
        id: "u1",
        name: "Huỳnh Dương Xuân Nhật",
        avatarURL: nil,
        departmentName: "CEVC3",
        role: "Engineer",
        level: "Legend Hero",
        awardTypes: [.mvp, .topTalent]
    )

    let sampleAwards = [
        Award(id: "a1", type: .mvp, recipientName: "Huỳnh Dương Xuân Nhật", criteria: []),
        Award(id: "a2", type: .topTalent, recipientName: "Huỳnh Dương Xuân Nhật", criteria: [])
    ]

    let sampleKudo = Kudo(
        id: "k1",
        sender: User(id: "u2", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
        recipients: [User(id: "u1", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")],
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

    ProfileSelfView(
        user: sampleUser,
        awards: sampleAwards,
        onEdit: {},
        onOpenAward: { _ in },
        kudos: [sampleKudo, sampleKudo, sampleKudo],
        kudosReceivedCount: 5,
        kudosSentCount: 5,
        onOpenSecretBox: {},
        onCopyKudoLink: { _ in },
        onViewKudoDetail: { _ in }
    )
}
