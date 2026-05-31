// KudosStatsBlock.swift
// MockProjectAIDD
//
// Presentational sub-view for the personal stats card (D.1).
// Shows bordered stats rows + "Mở Secret Box" button.
// Design source: MoMorph fO0Kt19sZZ, node 6885:9223.
// Binds to: KudosStats (already defined in Models layer).

import SwiftUI

struct KudosStatsBlock: View {
    let stats: KudosStats
    var onOpenSecretBox: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            statsCard
            Spacer().frame(height: 0)
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Bordered stats card (D.1)

    private var statsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Row D.1.2: Kudos received
            statsRow(
                label: "Số Kudos bạn nhận được:",
                value: "\(stats.kudosReceived)"
            )

            // Row D.1.3: Kudos sent
            statsRow(
                label: "Số Kudos bạn đã gửi:",
                value: "\(stats.kudosSent)"
            )

            // Row D.1.4: Hearts received (with optional x2 fire badge)
            heartsRow

            // Divider D.1.5
            Rectangle()
                .fill(Color(hex: "2E3940"))
                .frame(maxWidth: .infinity)
                .frame(height: 1)

            // Row D.1.6: Secret boxes opened
            statsRow(
                label: "Số Secret Box bạn đã mở:",
                value: "\(stats.secretBoxesOpened)"
            )

            // Row D.1.7: Secret boxes unopened
            statsRow(
                label: "Số Secret Box chưa mở:",
                value: "\(stats.secretBoxesUnopened)"
            )

            // Button: Mở Secret Box
            openSecretBoxButton
        }
        .padding(12)
        .background(Color.kudosOverlayBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.kudosBorderMuted, lineWidth: 0.794)
        )
    }

    // MARK: - Generic label/value row

    private func statsRow(label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(label)
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            Text(value)
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.bold)
                .foregroundStyle(Color.kudosAccent)
                .lineLimit(1)
        }
        .frame(height: 20)
    }

    // MARK: - Hearts row with optional x2 fire badge (D.1.4)

    private var heartsRow: some View {
        HStack(spacing: 6) {
            Text("Số tim bạn nhận được:")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.light)
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
            Spacer()
            if stats.isDoubleBonusActive {
                Image("X2FireBadge")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 29)
            }
            Text("\(stats.heartsReceived)")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.bold)
                .foregroundStyle(Color.kudosAccent)
                .lineLimit(1)
        }
        .frame(minHeight: 29)
    }

    // MARK: - Open Secret Box button (D.1 bottom)

    private var openSecretBoxButton: some View {
        let isDisabled = stats.secretBoxesUnopened == 0
        // `.disabled(isDisabled)` below already blocks the tap when unopened == 0.
        return Button(action: onOpenSecretBox) {
            HStack(spacing: 8) {
                Image(systemName: "gift")
                    .font(.system(size: 16))
                    .foregroundStyle(isDisabled ? Color.kudosDark.opacity(0.4) : Color.kudosDark)
                Text("Mở Secret Box")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(isDisabled ? Color.kudosDark.opacity(0.4) : Color.kudosDark)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(isDisabled ? Color.kudosAccent.opacity(0.4) : Color.kudosAccent)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .disabled(isDisabled)
    }
}

// MARK: - Preview

#Preview("KudosStatsBlock — active") {
    ScrollView {
        KudosStatsBlock(
            stats: KudosStats.sample,
            onOpenSecretBox: {}
        )
        .padding(.vertical, 16)
    }
    .background(Color(hex: "00101A"))
}

#Preview("KudosStatsBlock — no boxes") {
    ScrollView {
        KudosStatsBlock(
            stats: KudosStats(
                kudosReceived: 25,
                kudosSent: 25,
                heartsReceived: 25,
                isDoubleBonusActive: false,
                secretBoxesOpened: 25,
                secretBoxesUnopened: 0
            ),
            onOpenSecretBox: {}
        )
        .padding(.vertical, 16)
    }
    .background(Color(hex: "00101A"))
}
