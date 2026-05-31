// KudosBoardView.swift
// MockProjectAIDD
//
// Sun*Kudos board screen — presentational.
// Layout mirrors HomeView: outer ZStack → full-screen dark base → ScrollView with
// keyvisual image anchored at top → floating AwardTopNavigationBar overlay.
//
// Sections (top to bottom in scroll):
//   [clearance 80pt] → KudosHeroSection → KudosSendCTAButton →
//   KudosHighlightSection → SpotlightBoardSection → KudosAllSection
//
// Filter dropdowns are owned by KudosHighlightSection (anchored beneath their
// buttons); the selected hashtag/department is tracked here to drive the button label.

import SwiftUI

// MARK: - KudosBoardView

struct KudosBoardView: View {

    // MARK: Data props
    let kudos: [Kudo]
    let hashtags: [Hashtag]
    let departments: [Department]
    let stats: KudosStats?
    let giftRecipients: [GiftRecipient]
    let spotlightTotal: Int

    // MARK: Action callbacks
    var onSelectHashtag: (Hashtag?) -> Void
    var onSelectDepartment: (Department?) -> Void
    var onOpenKudo: (Kudo) -> Void
    var onSendKudo: (() -> Void)? = nil
    var onOpenSecretBox: () -> Void = {}
    var onViewAll: () -> Void = {}

    // MARK: Header props
    var selectedLanguage: AppLanguage = .vn
    var unreadNotificationCount: Int = 0
    var onSearch: () -> Void = {}
    var onBell: () -> Void = {}
    var onLanguage: () -> Void = {}

    // MARK: Local state
    @State private var highlightPage: Int = 0
    @State private var selectedHashtag: Hashtag?
    @State private var selectedDepartment: Department?

    private var highlightedKudos: [Kudo] {
        kudos.filter(\.isHighlighted).sorted { $0.reactionCount > $1.reactionCount }
    }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .top) {
            // Full-screen dark base
            Color(hex: "00101A").ignoresSafeArea()

            // Scrollable content
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .top) {
                        // Keyvisual background anchored at top of scroll content.
                        // Height ~480pt mirrors HomeView; covers header + hero + CTA.
                        Image("kudos-keyvisual-bg")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 480, maxHeight: 480)
                            .clipped()
                            .frame(maxWidth: .infinity, alignment: .top)

                        // Content column layered over keyvisual
                        VStack(spacing: 0) {
                            // Clearance below floating header (~64pt header + status bar)
                            Color.clear.frame(height: 80)

                            // Hero: logo + KUDOS wordmark + eyebrow text
                            KudosHeroSection()
                                .padding(.horizontal, 20)

                            // Send CTA
                            KudosSendCTAButton(onSendKudo: onSendKudo)
                                .padding(.horizontal, 20)
                                .padding(.top, 16)

                            // Highlight carousel + filter dropdowns
                            KudosHighlightSection(
                                kudos: highlightedKudos.isEmpty ? kudos : highlightedKudos,
                                currentPage: $highlightPage,
                                selectedHashtag: selectedHashtag,
                                selectedDepartment: selectedDepartment,
                                hashtags: hashtags,
                                departments: departments,
                                onSelectHashtag: { tag in
                                    selectedHashtag = tag
                                    onSelectHashtag(tag)
                                },
                                onSelectDepartment: { dept in
                                    selectedDepartment = dept
                                    onSelectDepartment(dept)
                                },
                                onOpenKudo: onOpenKudo
                            )
                            .padding(.top, 24)
                            .zIndex(1)

                            SpotlightBoardSection(totalKudos: spotlightTotal)
                                .padding(.top, 24)

                            KudosAllSection(
                                kudos: kudos,
                                stats: stats,
                                giftRecipients: giftRecipients,
                                onOpenSecretBox: onOpenSecretBox,
                                onOpenKudo: onOpenKudo,
                                onViewAll: onViewAll
                            )
                            .padding(.top, 24)
                            .padding(.bottom, 100)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .ignoresSafeArea(edges: .top)

            // Floating header overlay
            AwardTopNavigationBar(
                onLanguage: onLanguage,
                onSearch: onSearch,
                onNotifications: onBell,
                language: selectedLanguage,
                unreadCount: unreadNotificationCount
            )
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview

private let sampleKudos: [Kudo] = [
    Kudo(
        id: "k1",
        sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
        recipients: [User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")],
        message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất...",
        hashtags: [
            Hashtag(id: "h1", name: "#Dedicated", group: nil),
            Hashtag(id: "h2", name: "#Inspiring", group: nil)
        ],
        isAnonymous: false,
        createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
        reactionCount: 1000,
        isHighlighted: true
    )
]

private let sampleHashtags = [
    Hashtag(id: "h1", name: "#Dedicated", group: nil),
    Hashtag(id: "h2", name: "#Inspiring", group: nil),
    Hashtag(id: "h3", name: "#TeamPlayer", group: nil)
]

private let sampleDepartments = [
    Department(id: "d1", name: "CEVC2"),
    Department(id: "d5", name: "OPD"),
    Department(id: "d6", name: "Infra")
]

private let sampleGiftRecipients = [
    GiftRecipient(id: "g1", name: "Huỳnh Dương Xuân", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
    GiftRecipient(id: "g2", name: "Dương Xuân Huỳnh", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
    GiftRecipient(id: "g3", name: "Nguyễn Bá Chức", avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA")
]

#Preview {
    KudosBoardView(
        kudos: sampleKudos,
        hashtags: sampleHashtags,
        departments: sampleDepartments,
        stats: .sample,
        giftRecipients: sampleGiftRecipients,
        spotlightTotal: 388,
        onSelectHashtag: { _ in },
        onSelectDepartment: { _ in },
        onOpenKudo: { _ in },
        onSendKudo: {},
        onOpenSecretBox: {},
        onViewAll: {},
        selectedLanguage: .vn,
        unreadNotificationCount: 2,
        onSearch: {},
        onBell: {},
        onLanguage: {}
    )
}
