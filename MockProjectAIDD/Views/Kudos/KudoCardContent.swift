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

struct KudoCardActions: View {
    let reactionCount: Int
    var onCopyLink: (() -> Void)?
    var onViewDetail: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: 1.85) {
                Text(reactionCount.formatted())
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosDark)
                Image(systemName: "heart.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(Color.kudosHashtag)
            }
            .frame(width: 44, alignment: .leading)

            Spacer()

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
                            .font(.system(size: 10))
                            .foregroundStyle(Color.kudosDark)
                    }
                    .padding(4)
                    .frame(height: 24)
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
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.kudosDark)
                    }
                    .padding(4)
                    .frame(height: 24)
                    .contentShape(Rectangle())
                }
            }
        }
        .frame(height: 24)
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
