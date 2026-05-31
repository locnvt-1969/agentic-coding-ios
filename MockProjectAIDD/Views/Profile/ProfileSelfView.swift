// ProfileSelfView.swift
// MockProjectAIDD
//
// Root composer for "Profile bản thân" screen.
// Composes: ProfileHeader + ProfileBadges + ProfileStats + ProfileKudosSection.
// Presentational: data + callbacks as props. No service calls, no ViewModel ownership.
//   ProfileSelfView(user:stats:onEdit:kudos:kudosReceivedCount:
//                   kudosSentCount:onOpenSecretBox:onCopyKudoLink:onViewKudoDetail:)
//   — edit pencil is a ProfileSelfView-only overlay; ProfileHeader stays viewer-agnostic.

import SwiftUI

struct ProfileSelfView: View {
    let user: User
    let stats: ProfileStatsData
    var onEdit: () -> Void = {}

    // Kudos filter state — owned here, passed as binding into section
    @State private var kudosFilter: KudosFilterOption = .sent

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

                    // 2. Icon collection (self → empty + "của tôi")
                    ProfileBadges(valueIcons: user.collectedValueIcons)
                        .padding(.horizontal, 24)
                        .padding(.top, 24)

                    // 3. Stats card
                    ProfileStats(
                        stats: stats,
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
}

// MARK: - Preview

#Preview("ProfileSelfView - sample data") {
    let sampleUser = User(
        id: "u1",
        name: "Huỳnh Dương Xuân Nhật",
        avatarURL: nil,
        departmentName: "CEVC3",
        role: "Engineer",
        level: "Legend Hero",
        collectedValueIcons: []
    )

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
        isHighlighted: true,
        isSpam: true
    )

    ProfileSelfView(
        user: sampleUser,
        stats: .sample,
        onEdit: {},
        kudos: [sampleKudo, sampleKudo, sampleKudo],
        kudosReceivedCount: 5,
        kudosSentCount: 5,
        onOpenSecretBox: {},
        onCopyKudoLink: { _ in },
        onViewKudoDetail: { _ in }
    )
}
