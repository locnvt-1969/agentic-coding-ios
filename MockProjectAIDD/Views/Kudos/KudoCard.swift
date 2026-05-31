// KudoCard.swift
// MockProjectAIDD
//
// Reusable kudo card — highlighted style.
// Presentational only: no service calls, no ViewModel ownership.
// Anonymity invariant: always read sender via kudo.resolvedSender (enforced in KudoCardHeader).
// Sub-views: KudoCardHeader + KudoParticipantInfo (KudoCardHeader.swift),
//            KudoCardContent + KudoCardActions (KudoCardContent.swift).
// Color tokens: Color+KudosTokens.swift.

import SwiftUI

// MARK: - KudoCard

struct KudoCard: View {
    let kudo: Kudo
    var onCopyLink: (() -> Void)?
    var onViewDetail: ((Kudo) -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            KudoCardHeader(kudo: kudo)
            Divider().background(Color.kudosBorder)
            KudoCardContent(kudo: kudo)
            Divider().background(Color.kudosBorder)
            KudoCardActions(
                reactionCount: kudo.reactionCount,
                onCopyLink: onCopyLink,
                onViewDetail: onViewDetail.map { action in { action(kudo) } }
            )
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.kudosCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.kudosBorder, lineWidth: 1)
        )
        .overlay(alignment: .topTrailing) {
            if kudo.isSpam { spamBadge }
        }
    }

    // "Spam" pill shown when the kudo is flagged by moderation (top-trailing corner).
    private var spamBadge: some View {
        Text("Spam")
            .font(.custom("Montserrat-Medium", size: 12))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.kudosSpamBg)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .offset(x: 4, y: -8)
    }
}

// MARK: - Preview

#Preview("KudoCard - Named sender") {
    KudoCard(
        kudo: Kudo(
            id: "k1",
            sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
            recipients: [User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")],
            message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất nhiều...",
            hashtags: [
                Hashtag(id: "h1", name: "#Dedicated", group: nil),
                Hashtag(id: "h2", name: "#Inspiring", group: nil)
            ],
            isAnonymous: false,
            createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
            reactionCount: 1000,
            isHighlighted: true
        ),
        onCopyLink: {},
        onViewDetail: { _ in }
    )
    .padding()
    .background(Color(hex: "00101A"))
}

#Preview("KudoCard - Anonymous sender") {
    KudoCard(
        kudo: Kudo(
            id: "k2",
            sender: nil,
            recipients: [User(id: "u3", name: "Nguyễn Bá Chức", departmentName: "CEVC10")],
            message: "Cảm ơn em đã luôn cố gắng và nỗ lực!",
            hashtags: [Hashtag(id: "h3", name: "#Inspiring", group: nil)],
            isAnonymous: true,
            createdAt: Date(),
            reactionCount: 42,
            isHighlighted: false
        )
    )
    .padding()
    .background(Color(hex: "00101A"))
}
