// SecretBoxClosedView.swift
// MockProjectAIDD
//
// Closed state — box not yet opened.
// Presentational only. Tap on box image triggers onOpen callback.
// Layout sourced from Figma [iOS] Open secret box (kQk65hSYF2).

import SwiftUI

struct SecretBoxClosedView: View {
    let boxCount: Int
    let onOpen: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            Spacer().frame(height: 44)
            boxImage
            divider
            countRow
        }
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

            Text("Click vào box để mở")
                .font(.custom("Montserrat", size: 14).weight(.medium))
                .foregroundStyle(Color.secretBoxBodyText)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Box image (tappable)

    private var boxImage: some View {
        Button(action: onOpen) {
            Image("secretbox_closed_box")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 320, height: 320)
        }
        .buttonStyle(.plain)
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
}

// MARK: - Preview

#Preview("Closed") {
    SecretBoxClosedView(boxCount: 5, onOpen: {})
        .padding(.horizontal, 7)
        .background(Color.secretBoxDark)
        .frame(width: 375)
}
