// ViewKudoHighlightCard.swift
// MockProjectAIDD
//
// Main kudo highlight card shown at the top of the Kudo detail screen.
// Composes: participants row, message box, image strip, action bar.

import SwiftUI

// MARK: - ViewKudoHighlightCard

struct ViewKudoHighlightCard: View {
    let kudo: Kudo
    let formattedDate: String
    let kudoTitle: String
    let hashtagsLine: String
    var onReact: () -> Void

    var body: some View {
        // Figma card: border 1pt #FFEA9E, bg #FFF8E1, radius 8, padding 8/12
        VStack(alignment: .leading, spacing: 8) {
            // Header: sender → arrow → recipient
            ViewKudoParticipantsRow(kudo: kudo)

            // Divider
            Rectangle()
                .fill(Color.kudosBorder)
                .frame(maxWidth: .infinity)
                .frame(height: 1)

            // Timestamp — Figma: Montserrat 10pt Medium, #999, left
            Text(formattedDate)
                .font(.custom("Montserrat", size: 10))
                .fontWeight(.medium)
                .foregroundStyle(Color.kudosMuted)
                .frame(maxWidth: .infinity, alignment: .leading)
                .tracking(0.231)

            // Kudo title — Figma: Montserrat 10pt Bold, #00101A, centered
            if !kudoTitle.isEmpty {
                Text(kudoTitle)
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.kudosDark)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .tracking(0.231)
            }

            // Message body — Figma: tinted box, full message (no line limit on detail)
            ViewKudoMessageBox(message: kudo.message)

            // Attached images (hashtag thumbnail row)
            ViewKudoImageStrip()

            // Hashtags — Figma: Montserrat 10pt Regular, #D4271D
            if !hashtagsLine.isEmpty {
                Text(hashtagsLine)
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosHashtag)
                    .tracking(0.231)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }

            // Divider
            Rectangle()
                .fill(Color.kudosBorder)
                .frame(maxWidth: .infinity)
                .frame(height: 1)

            // Action bar: heart count | copy link | view detail
            ViewKudoActionBar(reactionCount: kudo.reactionCount, onReact: onReact)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(Color.kudosCardBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.kudosBorder, lineWidth: 1)
        )
    }
}
