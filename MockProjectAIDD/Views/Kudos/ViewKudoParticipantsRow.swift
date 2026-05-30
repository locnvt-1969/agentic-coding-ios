// ViewKudoParticipantsRow.swift
// MockProjectAIDD
//
// Sender → arrow → recipient row in the kudo detail card.
// Anonymity: sender read ONLY via kudo.resolvedSender.
// When resolvedSender is nil (anonymous), shows "Ẩn danh" / "Người gửi ẩn danh".

import SwiftUI

// MARK: - ViewKudoParticipantsRow

struct ViewKudoParticipantsRow: View {
    let kudo: Kudo

    var body: some View {
        HStack(spacing: 8) {
            // Sender side — resolvedSender is nil when kudo.isAnonymous is true
            ViewKudoParticipantInfo(
                user: kudo.resolvedSender,
                anonymousDisplayName: "Ẩn danh",
                anonymousSubLabel: "Người gửi ẩn danh",
                isSender: true,
                textAlignment: .leading
            )

            // Arrow icon — Figma: 16×16
            Image(systemName: "arrow.right")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(Color.kudosMuted)
                .frame(width: 16, height: 16)

            // Recipient side (always visible)
            if let recipient = kudo.recipients.first {
                ViewKudoParticipantInfo(
                    user: recipient,
                    anonymousDisplayName: nil,
                    anonymousSubLabel: nil,
                    isSender: false,
                    textAlignment: .leading
                )
            }

            Spacer()
        }
        .frame(height: 62)
    }
}
