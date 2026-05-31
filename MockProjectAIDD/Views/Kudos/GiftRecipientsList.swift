// GiftRecipientsList.swift
// MockProjectAIDD
//
// Presentational sub-view for the top-10 gift recipients card (D.3).
// Shows: title "10 SUNNER NHẬN QUÀ MỚI NHẤT", list of recipient rows,
// or an empty state message when the list is empty.
// Design source: MoMorph fO0Kt19sZZ, node 6885:9255.
// Binds to: GiftRecipient (already defined in Models layer).

import SwiftUI

struct GiftRecipientsList: View {
    let recipients: [GiftRecipient]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            recipientsCard
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Bordered card (D.3)

    private var recipientsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title D.3.1
            Text("10 SUNNER NHẬN QUÀ MỚI NHẤT")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.bold)
                .foregroundStyle(Color.kudosAccent)
                .frame(maxWidth: .infinity, alignment: .center)
                .lineLimit(1)

            if recipients.isEmpty {
                Text("Chưa có dữ liệu")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosMuted)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 12)
            } else {
                VStack(spacing: 12) {
                    ForEach(recipients) { recipient in
                        recipientRow(recipient)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.kudosOverlayBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.kudosBorderMuted, lineWidth: 0.794)
        )
    }

    // MARK: - Single recipient row (D.3.2)

    private func recipientRow(_ recipient: GiftRecipient) -> some View {
        HStack(alignment: .center, spacing: 6) {
            // Circular avatar — 32×32, white border 1.5pt
            avatarView(urlString: recipient.avatarURL)

            // Name + reward text stacked
            VStack(alignment: .leading, spacing: 2) {
                Text(recipient.name)
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.kudosAccent)
                    .lineLimit(1)

                Text(recipient.rewardText)
                    .font(.custom("Montserrat", size: 12))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }

            Spacer()
        }
        .frame(height: 38)
    }

    // MARK: - Avatar helper

    @ViewBuilder
    private func avatarView(urlString: String?) -> some View {
        Group {
            if let urlString, let url = URL(string: urlString) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    default:
                        Image("SampleAvatar")
                            .resizable()
                            .scaledToFill()
                    }
                }
            } else {
                Image("SampleAvatar")
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: 32, height: 32)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 1.5)
        )
    }
}

// MARK: - Preview

#Preview("GiftRecipientsList — populated") {
    let samples: [GiftRecipient] = [
        GiftRecipient(id: "g1", name: "Huỳnh Dương Xuân",  avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g2", name: "Huỳnh Dương Xuân",  avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
        GiftRecipient(id: "g3", name: "Huỳnh Dương Xuân",  avatarURL: nil, rewardText: "Nhận được 1 áo phông SAA"),
    ]
    return ScrollView {
        GiftRecipientsList(recipients: samples)
            .padding(.vertical, 16)
    }
    .background(Color(hex: "00101A"))
}

#Preview("GiftRecipientsList — empty") {
    ScrollView {
        GiftRecipientsList(recipients: [])
            .padding(.vertical, 16)
    }
    .background(Color(hex: "00101A"))
}
