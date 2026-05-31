// NotificationsTopNav.swift
// MockProjectAIDD
//
// Top navigation bar for the Notifications screen — designed to be pinned via
// `.safeAreaInset(edge: .top)`. A 42pt row with a dark→transparent gradient that
// bleeds up behind the status bar. Presentational only.

import SwiftUI

struct NotificationsTopNav: View {
    var onBack: (() -> Void)? = nil

    var body: some View {
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
        .frame(height: 42)
        .frame(maxWidth: .infinity)
        .background(gradientBackground.ignoresSafeArea(edges: .top))
    }

    private var gradientBackground: some View {
        LinearGradient(
            stops: [
                .init(color: Color(hex: "#00101A"),               location: 0.0000),
                .init(color: Color(hex: "#00101A").opacity(0.30), location: 0.7644),
                .init(color: Color(hex: "#00101A").opacity(0.10), location: 0.9279),
                .init(color: Color(hex: "#00101A").opacity(0.00), location: 1.0000),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .opacity(0.9)
    }
}

#Preview {
    ZStack(alignment: .top) {
        Color.black.ignoresSafeArea()
        NotificationsTopNav(onBack: {})
    }
}
