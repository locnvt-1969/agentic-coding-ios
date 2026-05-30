// ProfileSendKudoButton.swift
// MockProjectAIDD
//
// "Gửi lời cảm ơn và ghi nhận" CTA button — other-user profile only.
// Design: mms_A.1_Button ghi nhận — height 40, border #998C5F, bg rgba(FFEA9E, 0.10).
// Presentational only. Call onTap when user presses.

import SwiftUI

struct ProfileSendKudoButton: View {
    let recipientName: String
    var onTap: () -> Void = {}

    private var label: String {
        "Gửi lời cảm ơn và ghi nhận tới \(recipientName)..."
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                Image(systemName: "pencil")
                    .frame(width: 24, height: 24)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(Color.white)

                Text(label)
                    .font(.custom("Montserrat-Medium", size: 14))
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            .padding(.horizontal, 10)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(Color.profileNameHighlight.opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.profileBorderMuted, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("ProfileSendKudoButton") {
    ZStack {
        Color.profileDark
        ProfileSendKudoButton(
            recipientName: "Huỳnh Dương Xuân Nhật",
            onTap: {}
        )
        .padding(.horizontal, 20)
    }
}
