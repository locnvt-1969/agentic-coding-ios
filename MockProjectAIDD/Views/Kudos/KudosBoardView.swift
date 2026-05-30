// KudosBoardView.swift
// MockProjectAIDD
//
// Sun*Kudos board screen — presentational.
// Sections: hero KV, "send kudos" CTA, Highlight carousel + filters, All Kudos list.
// Contract: accepts data + callbacks only, no service calls.
// M2: `kudos` is a pre-filtered array injected by the parent; filter selection callbacks
//     (onSelectHashtag / onSelectDepartment) signal intent upward — the parent re-injects
//     the filtered result on the next render cycle.

import SwiftUI

// MARK: - KudosBoardView

struct KudosBoardView: View {
    // MARK: Public interface
    let kudos: [Kudo]
    let hashtags: [Hashtag]
    let departments: [Department]
    var onSelectHashtag: (Hashtag?) -> Void
    var onSelectDepartment: (Department?) -> Void
    var onOpenKudo: (Kudo) -> Void
    /// Called when the user taps "send kudos" CTA. nil = button is inert.
    var onSendKudo: (() -> Void)? = nil

    // MARK: Filter overlay state
    @State private var showHashtagFilter = false
    @State private var showDepartmentFilter = false
    @State private var selectedHashtag: Hashtag?
    @State private var selectedDepartment: Department?

    // MARK: Highlight carousel page
    @State private var highlightPage: Int = 0

    private var highlightedKudos: [Kudo] { kudos.filter(\.isHighlighted) }

    // MARK: Body

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    KudosKeyVisualSection()

                    KudosSendCTAButton(onSendKudo: onSendKudo)
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    KudosHighlightSection(
                        kudos: highlightedKudos.isEmpty ? kudos : highlightedKudos,
                        currentPage: $highlightPage,
                        selectedHashtag: selectedHashtag,
                        selectedDepartment: selectedDepartment,
                        onShowHashtagFilter: { showHashtagFilter = true },
                        onShowDepartmentFilter: { showDepartmentFilter = true },
                        onOpenKudo: onOpenKudo
                    )
                    .padding(.top, 24)

                    KudosAllSection(kudos: kudos, onOpenKudo: onOpenKudo)
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                }
            }
            .background(Color(hex: "00101A"))

            if showHashtagFilter {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showHashtagFilter = false }

                FilterOverlay(
                    items: hashtags,
                    selectedID: selectedHashtag?.id,
                    labelKeyPath: \.name,
                    onSelect: { tag in
                        selectedHashtag = tag
                        onSelectHashtag(tag)
                        showHashtagFilter = false
                    },
                    onDismiss: { showHashtagFilter = false }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 20)
                .padding(.top, 400)
                .transition(.opacity)
            }

            if showDepartmentFilter {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showDepartmentFilter = false }

                FilterOverlay(
                    items: departments,
                    selectedID: selectedDepartment?.id,
                    labelKeyPath: \.name,
                    onSelect: { dept in
                        selectedDepartment = dept
                        onSelectDepartment(dept)
                        showDepartmentFilter = false
                    },
                    onDismiss: { showDepartmentFilter = false }
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding(.leading, 157)
                .padding(.top, 400)
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showHashtagFilter)
        .animation(.easeInOut(duration: 0.2), value: showDepartmentFilter)
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
    ),
    Kudo(
        id: "k2",
        sender: nil,
        recipients: [User(id: "u3", name: "Nguyễn Bá Chức", departmentName: "CEVC10")],
        message: "Cảm ơn em đã luôn cố gắng!",
        hashtags: [Hashtag(id: "h3", name: "#Inspiring", group: nil)],
        isAnonymous: true,
        createdAt: Date(),
        reactionCount: 42,
        isHighlighted: true
    ),
    Kudo(
        id: "k3",
        sender: User(id: "u4", name: "Mai phương Thúy", departmentName: "OPD"),
        recipients: [User(id: "u5", name: "Lê Kiều Trang", departmentName: "Infra")],
        message: "Cảm ơn chị vì sự hỗ trợ tận tình trong dự án vừa rồi!",
        hashtags: [Hashtag(id: "h4", name: "#Dedicated", group: nil)],
        isAnonymous: false,
        createdAt: Date(),
        reactionCount: 200,
        isHighlighted: false
    )
]

private let sampleHashtags = [
    Hashtag(id: "h1", name: "#Dedicated", group: nil),
    Hashtag(id: "h2", name: "#Inspiring", group: nil),
    Hashtag(id: "h3", name: "#TeamPlayer", group: nil)
]

private let sampleDepartments = [
    Department(id: "d1", name: "CEVC2"),
    Department(id: "d2", name: "CEVC3"),
    Department(id: "d3", name: "CEVC4"),
    Department(id: "d4", name: "CEVC1"),
    Department(id: "d5", name: "OPD"),
    Department(id: "d6", name: "Infra")
]

#Preview {
    KudosBoardView(
        kudos: sampleKudos,
        hashtags: sampleHashtags,
        departments: sampleDepartments,
        onSelectHashtag: { _ in },
        onSelectDepartment: { _ in },
        onOpenKudo: { _ in },
        onSendKudo: {}
    )
}
