// ViewKudoNavBar.swift
// MockProjectAIDD
//
// Top navigation bar for the Kudo detail screen.
// Uses onBack callback (consistent with AllKudosNavBar / SendKudoNavBar pattern).
// Does NOT read @Environment(\.dismiss) — caller is responsible for dismissal.

import SwiftUI

// MARK: - ViewKudoNavBar

struct ViewKudoNavBar: View {
    var onBack: () -> Void

    var body: some View {
        // Figma: TopNavigation height 89 (47 status bar + 42 content)
        // StatusBar is handled by the system; we render the 42pt content bar only.
        ZStack {
            // Left accessory: back icon (24×24 at x:7 within 42pt bar)
            HStack {
                Button { onBack() } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 24, height: 24)
                }
                .padding(.leading, 7)
                Spacer()
            }

            // Title: "Kudo" — Figma: Helvetica Neue 17pt Medium, white, centered
            Text("Kudo")
                .font(.custom("Helvetica Neue", size: 17))
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .tracking(0.5)
        }
        .frame(height: 42)
    }
}
