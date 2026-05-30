// KudosHighlightSection.swift
// MockProjectAIDD
//
// Highlight Kudos carousel section for KudosBoardView.
// Presentational only: no service calls.

import SwiftUI

// MARK: - KudosHighlightSection

struct KudosHighlightSection: View {
    let kudos: [Kudo]
    @Binding var currentPage: Int
    let selectedHashtag: Hashtag?
    let selectedDepartment: Department?
    let onShowHashtagFilter: () -> Void
    let onShowDepartmentFilter: () -> Void
    let onOpenKudo: (Kudo) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KudosSectionHeader(title: "HIGHLIGHT KUDOS", subtitle: "Sun* Annual Awards 2025")

            HStack(spacing: 8) {
                KudosFilterButton(
                    label: selectedHashtag.map(\.name) ?? "Hashtag",
                    onTap: onShowHashtagFilter
                )
                .frame(width: 129)

                KudosFilterButton(
                    label: selectedDepartment.map(\.name) ?? "Phòng ban",
                    onTap: onShowDepartmentFilter
                )
            }
            .padding(.horizontal, 20)

            if kudos.isEmpty {
                KudosEmptyState(message: "Chưa có kudos nổi bật")
                    .padding(.horizontal, 20)
            } else {
                TabView(selection: $currentPage) {
                    ForEach(Array(kudos.enumerated()), id: \.element.id) { index, kudo in
                        KudoCard(
                            kudo: kudo,
                            onCopyLink: {},
                            onViewDetail: { k in onOpenKudo(k) }
                        )
                        .padding(.horizontal, 20)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 280)

                HStack(spacing: 8) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.kudosAccent)

                    Text("\(currentPage + 1)/\(kudos.count)")
                        .font(.custom("Montserrat", size: 12))
                        .foregroundStyle(Color.white)

                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.kudosAccent)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Preview

#Preview("KudosHighlightSection") {
    let kudos: [Kudo] = [
        Kudo(
            id: "k1",
            sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
            recipients: [User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")],
            message: "Cảm ơn người em bình thường nhưng phi thường :D",
            hashtags: [Hashtag(id: "h1", name: "#Dedicated", group: nil)],
            isAnonymous: false,
            createdAt: Date(),
            reactionCount: 1000,
            isHighlighted: true
        )
    ]
    KudosHighlightSection(
        kudos: kudos,
        currentPage: .constant(0),
        selectedHashtag: nil,
        selectedDepartment: nil,
        onShowHashtagFilter: {},
        onShowDepartmentFilter: {},
        onOpenKudo: { _ in }
    )
    .background(Color(hex: "00101A"))
}
