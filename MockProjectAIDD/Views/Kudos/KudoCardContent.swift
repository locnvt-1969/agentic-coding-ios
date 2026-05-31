// KudoCardContent.swift
// MockProjectAIDD
//
// Content body and actions bar for KudoCard.
// H2 fix: DateFormatter is a private static let — one instance reused across renders.

import SwiftUI

// MARK: - KudoCardContent

struct KudoCardContent: View {
    let kudo: Kudo

    // H2: static formatter — allocated once, not per render
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm - MM/dd/yyyy"
        return f
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: kudo.createdAt)
    }

    private var hashtagsLine: String {
        kudo.hashtags.map(\.name).joined(separator: " ")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDate)
                .font(.custom("Montserrat", size: 10))
                .fontWeight(.medium)
                .foregroundStyle(Color.kudosMuted)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let firstHashtag = kudo.hashtags.first {
                Text(firstHashtag.name.uppercased().replacingOccurrences(of: "#", with: ""))
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.kudosDark)
                    .frame(maxWidth: .infinity, alignment: .center)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(kudo.message)
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosDark)
                    .lineSpacing(4)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(4)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.kudosPrimary.opacity(0.4))
            .clipShape(RoundedRectangle(cornerRadius: 5.554))
            .overlay(
                RoundedRectangle(cornerRadius: 5.554)
                    .stroke(Color.kudosBorder, lineWidth: 0.463)
            )

            if !kudo.hashtags.isEmpty {
                Text(hashtagsLine)
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosHashtag)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

// MARK: - KudoCardActions
// Layout matches design node mms_B.4.4_Action (I6885:9263;89:2972):
//   outer row: justifyContent space-between, width 250, height 24
//   Hearts group: width 44, height 16, gap 1.85 — count + heart icon (16×16)
//   Buttons group: width 173, height 24, gap 3.70 — CopyLink (79w) + XemChiTiet (90w)
//   Each button: padding 4, gap 4 between text and icon, height 24

struct KudoCardActions: View {
    let reactionCount: Int
    var onCopyLink: (() -> Void)?
    var onViewDetail: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            // Hearts group — width 44, height 16, gap 1.85
            HStack(spacing: 1.85) {
                Text(reactionCount.formatted())
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosDark)
                Image(systemName: "heart.fill")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .foregroundStyle(Color.kudosHashtag)
            }
            .frame(width: 44, height: 16, alignment: .leading)

            Spacer()

            // Buttons group — width 173, height 24, gap 3.70
            HStack(spacing: 3.7) {
                Button {
                    onCopyLink?()
                } label: {
                    HStack(spacing: 4) {
                        Text("Copy Link")
                            .font(.custom("Montserrat", size: 10))
                            .fontWeight(.medium)
                            .foregroundStyle(Color.kudosDark)
                        Image(systemName: "link")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.kudosDark)
                    }
                    .padding(4)
                    .frame(width: 79, height: 24)
                    .contentShape(Rectangle())
                }

                Button {
                    onViewDetail?()
                } label: {
                    HStack(spacing: 4) {
                        Text("Xem chi tiết")
                            .font(.custom("Montserrat", size: 10))
                            .fontWeight(.medium)
                            .foregroundStyle(Color.kudosDark)
                        Image(systemName: "arrow.up.right")
                            .resizable()
                            .frame(width: 16, height: 16)
                            .foregroundStyle(Color.kudosDark)
                    }
                    .padding(4)
                    .frame(width: 90, height: 24)
                    .contentShape(Rectangle())
                }
            }
            .frame(width: 173, height: 24)
        }
        .frame(width: 250, height: 24)
    }
}

// MARK: - Preview

#Preview("KudoCardContent") {
    KudoCardContent(
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
            reactionCount: 1000
        )
    )
    .padding()
    .background(Color.kudosCardBg)
}

#Preview("KudoCardActions") {
    KudoCardActions(
        reactionCount: 42,
        onCopyLink: {},
        onViewDetail: {}
    )
    .padding()
    .background(Color.kudosCardBg)
}
