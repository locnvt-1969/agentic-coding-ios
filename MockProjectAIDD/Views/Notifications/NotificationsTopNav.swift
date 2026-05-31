// NotificationsTopNav.swift
// MockProjectAIDD
//
// Top navigation bar for the Notifications screen.
// Design: dark gradient (#00101A → transparent, opacity 0.9) + back chevron + centered title.
// Presentational only — onBack callback injected from parent.

import SwiftUI

struct NotificationsTopNav: View {
    var onBack: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            gradientBackground
            navRow
        }
        .frame(maxWidth: .infinity, minHeight: 89)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Gradient

    private var gradientBackground: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: "#00101A"),               location: 0.0000),
                .init(color: Color(hex: "#00101A").opacity(0.30), location: 0.7644),
                .init(color: Color(hex: "#00101A").opacity(0.20), location: 0.8462),
                .init(color: Color(hex: "#00101A").opacity(0.15), location: 0.8870),
                .init(color: Color(hex: "#00101A").opacity(0.10), location: 0.9279),
                .init(color: Color(hex: "#00101A").opacity(0.05), location: 0.9639),
                .init(color: Color(hex: "#00101A").opacity(0.00), location: 1.0000),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .opacity(0.9)
        .frame(maxWidth: .infinity)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Nav row

    private var navRow: some View {
        HStack(spacing: 0) {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 42)
                    .contentShape(Rectangle())
            }

            Spacer()

            Text("Notifications")
                .font(.custom("Helvetica Neue", size: 17).weight(.medium))
                .tracking(0.5)
                .foregroundStyle(.white)

            Spacer()

            // Mirror back button to keep title centered
            Color.clear.frame(width: 44, height: 42)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        NotificationsTopNav(onBack: {})
    }
}
