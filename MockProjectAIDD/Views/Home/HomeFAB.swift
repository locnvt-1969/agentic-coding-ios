// HomeFAB.swift
// MockProjectAIDD
//
// mms_6 — Floating Action Button
// Single cream capsule (#FFEA9E) with two horizontal tap zones:
//   • Left:  pencil icon → opens WriteKudo form (mms_6.1 — Pen)
//   • Right: Sun* "S" logo → navigates to Kudos feed (mms_6.2 — IC_Kudos)
// A subtle vertical divider separates the two halves.
// Outer glow approximates Figma's `box-shadow: 0 0 6px 0 #FAE287`.

import SwiftUI

struct HomeFAB: View {

    // MARK: - Props
    let onPencilTap: () -> Void
    let onSKudosTap: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            // mms_6.1 — pencil (left half)
            Button(action: onPencilTap) {
                Image(systemName: "pencil")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(hex: "#00101A"))
                    .frame(width: 42, height: 48)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            // Vertical divider
            Rectangle()
                .fill(Color(hex: "#00101A").opacity(0.35))
                .frame(width: 1, height: 22)

            // mms_6.2 — Sun* S logo (right half)
            Button(action: onSKudosTap) {
                Image("home-s-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 22)
                    .frame(width: 42, height: 48)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .background(
            Capsule()
                .fill(Color(hex: "#FFEA9E"))
        )
        .shadow(color: Color(hex: "#FAE287").opacity(0.6), radius: 6, x: 0, y: 0)
        .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 4)
    }
}

#Preview {
    ZStack(alignment: .bottomTrailing) {
        Color(hex: "#060E16").ignoresSafeArea()
        HomeFAB(onPencilTap: {}, onSKudosTap: {})
            .padding(20)
    }
}
