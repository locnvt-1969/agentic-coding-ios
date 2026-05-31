// SecretBoxOpeningView.swift
// MockProjectAIDD
//
// Opening state — user just tapped, box animation playing.
// Presentational only. No callbacks — parent drives state forward.
// Layout sourced from Figma [iOS] Open secret box- action bấm mở (KUmv414uC9).

import SwiftUI

struct SecretBoxOpeningView: View {
    let boxCount: Int

    // Pulse scale animation on the box image
    @State private var isPulsing = false

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer().frame(height: 44)
            boxImage
            divider
            countRow
        }
        .onAppear { startPulse() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: 8) {
            Text("KHÁM PHÁ SECRET BOX CỦA BẠN")
                .font(.custom("Montserrat", size: 18).weight(.bold))
                .foregroundStyle(Color.secretBoxGold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)

            Rectangle()
                .fill(Color.secretBoxDivider)
                .frame(height: 1)

            Text("Đang mở...")
                .font(.custom("Montserrat", size: 14).weight(.medium))
                .foregroundStyle(Color.secretBoxBodyText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Box image (opening animation)

    private var boxImage: some View {
        Image("secretbox_opening_box")
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 320, height: 320)
            .scaleEffect(isPulsing ? 1.06 : 0.96)
            .animation(
                .easeInOut(duration: 0.45).repeatForever(autoreverses: true),
                value: isPulsing
            )
    }

    // MARK: - Divider

    private var divider: some View {
        Rectangle()
            .fill(Color.secretBoxDivider)
            .frame(height: 1)
            .padding(.top, 24)
    }

    // MARK: - Count row

    private var countRow: some View {
        HStack(spacing: 5) {
            Text("Secret box chưa mở")
                .font(.custom("Montserrat", size: 12).weight(.regular))
                .foregroundStyle(Color.secretBoxBodyText)

            Text(String(format: "%02d", boxCount))
                .font(.custom("Montserrat", size: 18).weight(.bold))
                .foregroundStyle(Color.secretBoxGold)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 24)
    }

    // MARK: - Animation

    private func startPulse() {
        isPulsing = true
    }
}

// MARK: - Preview

#Preview("Opening") {
    SecretBoxOpeningView(boxCount: 5)
        .padding(.horizontal, 7)
        .background(Color.secretBoxDark)
        .frame(width: 375)
}
