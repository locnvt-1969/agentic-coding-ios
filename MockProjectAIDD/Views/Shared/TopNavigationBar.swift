// TopNavigationBar.swift
// MockProjectAIDD
//
// Reusable presentational top bar for in-app screens.
// Purely presentational — exposes callbacks only. Visual values (colors, sizes)
// are refined against the MoMorph "Top Navigation" design during Track A.

import SwiftUI

struct TopNavigationBar: View {
    let title: String
    var showsBack: Bool = false
    var trailingSystemIcon: String? = nil
    var onBack: (() -> Void)? = nil
    var onTrailing: (() -> Void)? = nil

    var body: some View {
        HStack(spacing: 12) {
            if showsBack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                }
            }

            Text(title)
                .font(.headline)
                .lineLimit(1)

            Spacer()

            if let icon = trailingSystemIcon {
                Button(action: { onTrailing?() }) {
                    Image(systemName: icon)
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .frame(height: 44)
    }
}

#Preview {
    ZStack {
        Color.black
        TopNavigationBar(
            title: "Profile",
            showsBack: true,
            trailingSystemIcon: "bell.fill"
        )
    }
}
