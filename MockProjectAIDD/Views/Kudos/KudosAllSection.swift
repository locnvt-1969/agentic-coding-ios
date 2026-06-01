// KudosAllSection.swift
// MockProjectAIDD
//
// "All Kudos" list section for KudosBoardView.
// Presentational only: no service calls.
//
// Feed cards use full width with 20pt side margins (per user preference, matching
//   the carousel cards) — gap 12 between cards.
// "View all Kudos" button matches design node 6891:15987:
//   width 136, height 32, padding 10px 0, radius 4, gap 8, row centered.
//   Label: Montserrat 14 / weight 500 / color #FFFFFF.
//   Icon: arrow.up.right 24×24 white.
//   Always visible below feed (no expand/collapse toggle).

import SwiftUI

// MARK: - KudosAllSection

struct KudosAllSection: View {
    let kudos: [Kudo]
    let stats: KudosStats?
    let giftRecipients: [GiftRecipient]
    let onOpenSecretBox: () -> Void
    let onOpenKudo: (Kudo) -> Void
    var onToggleReaction: (Kudo) -> Void = { _ in }
    var onViewAll: () -> Void = {}

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KudosSectionHeader(title: "ALL KUDOS", subtitle: "Sun* Annual Awards 2025")

            if let stats {
                KudosStatsBlock(stats: stats, onOpenSecretBox: onOpenSecretBox)
            }

            if !giftRecipients.isEmpty {
                GiftRecipientsList(recipients: giftRecipients)
            }

            if kudos.isEmpty {
                KudosEmptyState(message: "Chưa có kudos nào")
                    .padding(.horizontal, 20)
            } else {
                // Feed cards: full width with 20pt side margins (matches the carousel cards).
                VStack(spacing: 12) {
                    ForEach(kudos.prefix(3)) { kudo in
                        KudoCard(
                            kudo: kudo,
                            onCopyLink: {},
                            onViewDetail: { k in onOpenKudo(k) },
                            onToggleReaction: { k in onToggleReaction(k) }
                        )
                        .padding(.horizontal, 20)
                    }
                }

                // "View all Kudos" button — always visible, navigates to full list
                // Design node 6891:15987: width 136, height 32, radius 4, gap 8, centered
                HStack {
                    Button(action: onViewAll) {
                        HStack(spacing: 8) {
                            Text("View all Kudos")
                                .font(.custom("Montserrat", size: 14))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.white)
                            Image(systemName: "arrow.up.right")
                                .resizable()
                                .frame(width: 24, height: 24)
                                .foregroundStyle(Color.white)
                        }
                        .padding(.vertical, 10)
                        .frame(width: 136, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                        .contentShape(Rectangle())
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview

#Preview("KudosAllSection") {
    let kudos: [Kudo] = [
        Kudo(
            id: "k1",
            sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
            recipients: [User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")],
            message: "Cảm ơn người em bình thường nhưng phi thường!",
            hashtags: [Hashtag(id: "h1", name: "#Dedicated", group: nil)],
            isAnonymous: false,
            createdAt: Date(),
            reactionCount: 42,
            isHighlighted: false
        ),
        Kudo(
            id: "k2",
            sender: nil,
            recipients: [User(id: "u3", name: "Nguyễn Bá Chức", departmentName: "CEVC10")],
            message: "Cảm ơn em đã luôn cố gắng và nỗ lực!",
            hashtags: [Hashtag(id: "h2", name: "#Inspiring", group: nil)],
            isAnonymous: true,
            createdAt: Date(),
            reactionCount: 10,
            isHighlighted: false
        )
    ]
    KudosAllSection(
        kudos: kudos,
        stats: .sample,
        giftRecipients: [
            GiftRecipient(id: "g1", name: "Huỳnh Dương Xuân", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
            GiftRecipient(id: "g2", name: "Dương Xuân Huỳnh", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA")
        ],
        onOpenSecretBox: {},
        onOpenKudo: { _ in },
        onViewAll: {}
    )
    .background(Color(hex: "00101A"))
}
