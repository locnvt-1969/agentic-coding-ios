// ViewKudoCardComponents.swift
// MockProjectAIDD
//
// Leaf components used inside the kudo detail card:
//   • ViewKudoMessageBox  — tinted message body
//   • ViewKudoImageStrip  — horizontal thumbnail strip (5 images)
//   • ViewKudoActionBar   — heart count + copy link + view detail

import SwiftUI

// MARK: - ViewKudoMessageBox

struct ViewKudoMessageBox: View {
    let message: String

    var body: some View {
        // Figma: background rgba(#FFEA9E, 0.40), border 0.463 #FFEA9E, radius 5.554, padding 4
        Text(message)
            .font(.custom("Montserrat", size: 10))
            .fontWeight(.regular)
            .foregroundStyle(Color.kudosDark)
            .lineSpacing(4)          // Figma lineHeight 14 ≈ 10pt + 4 spacing
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(4)
            .background(Color.kudosPrimary.opacity(0.40))
            .clipShape(RoundedRectangle(cornerRadius: 5.554))
            .overlay(
                RoundedRectangle(cornerRadius: 5.554)
                    .stroke(Color.kudosBorder, lineWidth: 0.463)
            )
    }
}

// MARK: - ViewKudoImageStrip

/// Horizontal strip of 5 thumbnail images (32×32 each).
/// Figma: 5 Image instances, 32×32, border 0.447 #998C5F, radius 8.043, bg #FFF.
struct ViewKudoImageStrip: View {
    private let count = 5

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<count, id: \.self) { _ in
                RoundedRectangle(cornerRadius: 8.043)
                    .fill(Color.white)
                    .frame(width: 32, height: 32)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8.043)
                            .stroke(Color.kudosBorderMuted, lineWidth: 0.447)
                    )
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.kudosMuted)
                    )
            }
        }
    }
}

// MARK: - ViewKudoActionBar

struct ViewKudoActionBar: View {
    let reactionCount: Int
    var isReacted: Bool = false
    var onReact: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // Hearts counter — Figma: count text + heart icon, left aligned
            Button(action: onReact) {
                HStack(spacing: 1.85) {
                    Text("\(reactionCount)")
                        .font(.custom("Montserrat", size: 10))
                        .fontWeight(.regular)
                        .foregroundStyle(Color.kudosDark)
                    Image(systemName: isReacted ? "heart.fill" : "heart")
                        .font(.system(size: 10))
                        .foregroundStyle(Color.kudosHashtag)
                }
            }
            .buttonStyle(.plain)
            .frame(minWidth: 29, alignment: .leading)

            Spacer()

            // Right buttons: Copy Link | Xem chi tiết
            HStack(spacing: 3.7) {
                Button {
                    // Copy link callback not exposed on ViewKudoView contract —
                    // use UIPasteboard or inject if needed from parent.
                } label: {
                    HStack(spacing: 4) {
                        Text("Copy Link")
                            .font(.custom("Montserrat", size: 10))
                            .fontWeight(.medium)
                            .foregroundStyle(Color.kudosDark)
                            .tracking(0.069)
                        Image(systemName: "link")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.kudosDark)
                    }
                    .padding(4)
                    .frame(height: 24)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)

                Button { } label: {
                    HStack(spacing: 4) {
                        Text("Xem chi tiết")
                            .font(.custom("Montserrat", size: 10))
                            .fontWeight(.medium)
                            .foregroundStyle(Color.kudosDark)
                            .tracking(0.069)
                        Image(systemName: "arrow.right")
                            .font(.system(size: 10))
                            .foregroundStyle(Color.kudosDark)
                    }
                    .padding(4)
                    .frame(height: 24)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(height: 24)
    }
}
