// AllKudosView.swift
// MockProjectAIDD
//
// Presentational "All Kudos" list screen — phase 13.
// Design: https://momorph.ai/files/9ypp4enmFmdK3YAFJLIu6C/screens/j_a2GQWKDJ
// Contract: AllKudosView(kudos:onOpenKudo:onLoadMore:onBack:)
// No service calls. No ViewModel ownership. Callbacks only.

import SwiftUI

// MARK: - AllKudosView

struct AllKudosView: View {
    // MARK: Public contract
    let kudos: [Kudo]
    var onOpenKudo: (Kudo) -> Void
    var onLoadMore: () -> Void
    var onBack: (() -> Void)? = nil

    // MARK: Body

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color(hex: "00101A")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                AllKudosNavBar(onBack: onBack)
                AllKudosHeader()
                AllKudosListContent(
                    kudos: kudos,
                    onOpenKudo: onOpenKudo,
                    onLoadMore: onLoadMore
                )
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Preview

#Preview("All Kudos — loaded") {
    AllKudosView(
        kudos: [
            Kudo(
                id: "k1",
                sender: User(
                    id: "u1",
                    name: "Huỳnh Dương Xuân",
                    departmentName: "CEVC10",
                    awardTypes: [.mvp]
                ),
                recipients: [
                    User(
                        id: "u2",
                        name: "Dương Xuân Huỳnh",
                        departmentName: "CEVC10",
                        awardTypes: [.topTalent]
                    )
                ],
                message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất...",
                hashtags: [
                    Hashtag(id: "h1", name: "#Dedicated", group: nil),
                    Hashtag(id: "h2", name: "#Inspring", group: nil)
                ],
                isAnonymous: false,
                createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
                reactionCount: 1000,
                isHighlighted: true
            ),
            Kudo(
                id: "k2",
                sender: nil,
                recipients: [
                    User(
                        id: "u3",
                        name: "Dương Xuân Huỳnh",
                        departmentName: "CEVC10",
                        awardTypes: [.topTalent]
                    )
                ],
                message: "Cảm ơn em đã luôn nỗ lực và cống hiến cho nhóm!",
                hashtags: [
                    Hashtag(id: "h3", name: "#Dedicated", group: nil),
                    Hashtag(id: "h4", name: "#Inspring", group: nil)
                ],
                isAnonymous: true,
                createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
                reactionCount: 1000,
                isHighlighted: true
            ),
            Kudo(
                id: "k3",
                sender: User(
                    id: "u4",
                    name: "Huỳnh Dương Xuân",
                    departmentName: "CEVC10",
                    awardTypes: [.mvp]
                ),
                recipients: [
                    User(
                        id: "u5",
                        name: "Dương Xuân Huỳnh",
                        departmentName: "CEVC10",
                        awardTypes: [.topTalent]
                    )
                ],
                message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất...",
                hashtags: [
                    Hashtag(id: "h5", name: "#Dedicated", group: nil),
                    Hashtag(id: "h6", name: "#Inspring", group: nil)
                ],
                isAnonymous: false,
                createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
                reactionCount: 1000,
                isHighlighted: false
            ),
            Kudo(
                id: "k4",
                sender: User(
                    id: "u6",
                    name: "Huỳnh Dương Xuân",
                    departmentName: "CEVC10",
                    awardTypes: [.mvp]
                ),
                recipients: [
                    User(
                        id: "u7",
                        name: "Dương Xuân Huỳnh",
                        departmentName: "CEVC10",
                        awardTypes: [.topTalent]
                    )
                ],
                message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lục rất...",
                hashtags: [
                    Hashtag(id: "h7", name: "#Dedicated", group: nil),
                    Hashtag(id: "h8", name: "#Inspring", group: nil)
                ],
                isAnonymous: false,
                createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
                reactionCount: 1000,
                isHighlighted: false
            )
        ],
        onOpenKudo: { _ in },
        onLoadMore: {},
        onBack: {}
    )
}

#Preview("All Kudos — empty") {
    AllKudosView(
        kudos: [],
        onOpenKudo: { _ in },
        onLoadMore: {},
        onBack: {}
    )
}
