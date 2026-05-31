// SecretBoxStandbyView.swift
// MockProjectAIDD
//
// Standby state — box opened, reward revealed.
// Presentational only. No callbacks.
// Layout sourced from Figma [iOS] Open secret box- Standby (-LIblaeusT).

import SwiftUI

struct SecretBoxStandbyView: View {
    let reward: Gift?

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer().frame(height: 32)
            rewardImage
            divider
            rewardTitle
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("Chúc mừng bạn đã nhận được phần quà từ BTC SAA 2025")
                .font(.custom("Montserrat", size: 18).weight(.bold))
                .foregroundStyle(Color.secretBoxGold)
                .multilineTextAlignment(.center)
                .lineLimit(nil)
                .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.secretBoxDivider)
                .frame(height: 1)
        }
    }

    // MARK: - Reward image with glow

    private var rewardImage: some View {
        ZStack {
            // Glow halo behind reward item (from Figma: box-shadow #FFF3C5 42px)
            Circle()
                .fill(Color.secretBoxRewardGlow.opacity(0.35))
                .frame(width: 280, height: 280)
                .blur(radius: 40)

            if let rewardUIImage = UIImage(named: "secretbox_reward_item") {
                Image(uiImage: rewardUIImage)
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: 320, height: 320)
            } else {
                // Fallback placeholder when asset not yet bundled
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.secretBoxGold.opacity(0.15))
                    .frame(width: 320, height: 320)
                    .overlay(
                        Image(systemName: "gift.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.secretBoxGold)
                    )
            }
        }
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(Color.secretBoxDivider)
            .frame(height: 1)
            .padding(.top, 24)
    }

    // MARK: - Reward title

    private var rewardTitle: some View {
        Text(reward?.title ?? "Khăn Root Further")
            .font(.custom("Montserrat", size: 14).weight(.regular))
            .foregroundStyle(Color.secretBoxRewardText)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .padding(.top, 24)
    }
}

// MARK: - Preview

#Preview("Standby — with reward") {
    SecretBoxStandbyView(reward: Gift(id: "g1", title: "Khăn Root Further", detail: nil))
        .padding(.horizontal, 7)
        .background(Color.secretBoxDark)
        .frame(width: 375)
}

#Preview("Standby — no reward") {
    SecretBoxStandbyView(reward: nil)
        .padding(.horizontal, 7)
        .background(Color.secretBoxDark)
        .frame(width: 375)
}
