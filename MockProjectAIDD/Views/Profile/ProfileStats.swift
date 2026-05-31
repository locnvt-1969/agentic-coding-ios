// ProfileStats.swift
// MockProjectAIDD
//
// Presentational stats card — "Thống kê tổng quát".
// Design: mms_D.1_Thống kê tổng quat — dark container with 5 rows + CTA button.
// Reusable by phase-09 (viewer sees same stats block for other user).

import SwiftUI

// MARK: - ProfileStats
// ProfileStatsData lives in Models/ProfileStatsData.swift (shared with the service layer).

struct ProfileStats: View {
    let stats: ProfileStatsData
    /// "Mở Secret Box" CTA — pass nil to hide button (e.g. viewing another user's profile).
    var onOpenSecretBox: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            statsContent
            if let action = onOpenSecretBox {
                openSecretBoxButton(action: action)
            }
        }
        .padding(12)
        .background(Color.profileContainer)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.profileBorderMuted, lineWidth: 0.794)
        )
    }

    // MARK: Stats rows

    private var statsContent: some View {
        VStack(spacing: 12) {
            statsRow(label: "Số Kudos bạn nhận được:", value: stats.kudosReceived)
            statsRow(label: "Số Kudos bạn đã gửi:", value: stats.kudosSent)
            statsRow(label: "Số tim bạn nhận được:", value: stats.heartsReceived)

            // Divider between kudos stats and secret-box stats
            Rectangle()
                .fill(Color.profileDivider)
                .frame(height: 1)

            statsRow(label: "Số Secret Box bạn đã mở:", value: stats.secretBoxOpened)
            statsRow(label: "Số Secret Box chưa mở:", value: stats.secretBoxUnopened)
        }
    }

    private func statsRow(label: String, value: Int) -> some View {
        HStack {
            Text(label)
                .font(.custom("Montserrat-Light", size: 14))
                .foregroundStyle(Color.white)
                .tracking(0.25)
            Spacer()
            Text("\(value)")
                .font(.custom("Montserrat-Bold", size: 14))
                .foregroundStyle(Color.profileNameHighlight)
                .tracking(0.25)
        }
        .frame(height: 20)
    }

    // MARK: CTA button

    private func openSecretBoxButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text("Mở Secret Box")
                    .font(.custom("Montserrat-Medium", size: 14))
                    .foregroundStyle(Color.profileButtonText)
                Image(systemName: "shippingbox.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.profileButtonText)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.profileButtonBg)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("ProfileStats - with CTA") {
    ZStack {
        Color.profileDark
        ProfileStats(
            stats: .sample,
            onOpenSecretBox: {}
        )
        .padding(.horizontal, 20)
    }
}

#Preview("ProfileStats - no CTA (other user)") {
    ZStack {
        Color.profileDark
        ProfileStats(
            stats: .sample,
            onOpenSecretBox: nil
        )
        .padding(.horizontal, 20)
    }
}
