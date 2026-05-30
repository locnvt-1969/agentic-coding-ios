// KudosAllSection.swift
// MockProjectAIDD
//
// "All Kudos" list section for KudosBoardView.
// Presentational only: no service calls.

import SwiftUI

// MARK: - KudosAllSection

struct KudosAllSection: View {
    let kudos: [Kudo]
    let onOpenKudo: (Kudo) -> Void

    @State private var isExpanded = false

    private var visibleKudos: [Kudo] {
        isExpanded ? kudos : Array(kudos.prefix(3))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KudosSectionHeader(title: "ALL KUDOS", subtitle: "Sun* Annual Awards 2025")

            if kudos.isEmpty {
                KudosEmptyState(message: "Chưa có kudos nào")
                    .padding(.horizontal, 20)
            } else {
                VStack(spacing: 12) {
                    ForEach(visibleKudos) { kudo in
                        KudoCard(
                            kudo: kudo,
                            onCopyLink: {},
                            onViewDetail: { k in onOpenKudo(k) }
                        )
                        .padding(.horizontal, 20)
                    }
                }

                if kudos.count > 3 {
                    Button {
                        isExpanded.toggle()
                    } label: {
                        HStack(spacing: 8) {
                            Text(isExpanded ? "Thu gọn" : "View all Kudos")
                                .font(.custom("Montserrat", size: 14))
                                .fontWeight(.medium)
                                .foregroundStyle(Color.white)
                            Image(systemName: isExpanded ? "chevron.up" : "arrow.right")
                                .font(.system(size: 14))
                                .foregroundStyle(Color.white)
                        }
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 20)
                }
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
    KudosAllSection(kudos: kudos, onOpenKudo: { _ in })
        .background(Color(hex: "00101A"))
}
