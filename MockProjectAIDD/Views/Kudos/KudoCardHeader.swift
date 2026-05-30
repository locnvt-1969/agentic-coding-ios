// KudoCardHeader.swift
// MockProjectAIDD
//
// Header row for KudoCard: sender → arrow → recipient.
// Presentational only. Anonymity: always reads sender via kudo.resolvedSender.

import SwiftUI

// MARK: - KudoCardHeader

struct KudoCardHeader: View {
    let kudo: Kudo

    var body: some View {
        HStack(spacing: 8) {
            KudoParticipantInfo(
                user: kudo.resolvedSender,
                anonymousName: "Ẩn danh",
                isSender: true
            )

            Image(systemName: "arrow.right")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.kudosMuted)
                .frame(width: 16)

            if let recipient = kudo.recipients.first {
                KudoParticipantInfo(user: recipient, anonymousName: nil, isSender: false)
            }
        }
        .frame(height: 62)
    }
}

// MARK: - KudoParticipantInfo

struct KudoParticipantInfo: View {
    let user: User?
    let anonymousName: String?
    let isSender: Bool

    private var displayName: String {
        user?.name ?? anonymousName ?? "Unknown"
    }

    private var departmentLabel: String {
        user?.departmentName ?? ""
    }

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: "EEEEEE"))
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))

                if let urlString = user?.avatarURL?.absoluteString,
                   let url = URL(string: urlString) {
                    AsyncImage(url: url) { image in
                        image.resizable().scaledToFill()
                    } placeholder: {
                        Color(hex: "EEEEEE")
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 1))
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.kudosMuted)
                }
            }
            .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(displayName)
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosDark)
                    .lineLimit(1)
                    .frame(width: 109, alignment: .leading)

                if !departmentLabel.isEmpty {
                    Text(departmentLabel)
                        .font(.custom("Montserrat", size: 10))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.kudosMuted)
                        .lineLimit(1)
                }
            }
        }
        .frame(width: 109, height: 62)
    }
}

// MARK: - Preview

#Preview("KudoCardHeader - Named sender") {
    KudoCardHeader(
        kudo: Kudo(
            id: "k1",
            sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
            recipients: [User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")],
            message: "Preview",
            isAnonymous: false
        )
    )
    .padding()
    .background(Color.kudosCardBg)
}

#Preview("KudoCardHeader - Anonymous") {
    KudoCardHeader(
        kudo: Kudo(
            id: "k2",
            sender: nil,
            recipients: [User(id: "u3", name: "Nguyễn Bá Chức", departmentName: "CEVC10")],
            message: "Preview",
            isAnonymous: true
        )
    )
    .padding()
    .background(Color.kudosCardBg)
}
