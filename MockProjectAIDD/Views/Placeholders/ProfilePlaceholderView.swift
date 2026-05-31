// ProfilePlaceholderView.swift
// MockProjectAIDD
//
// Stub screen for the Profile tab. Shown when router.currentRoute == .profile.

import SwiftUI

struct ProfilePlaceholderView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        ZStack {
            Color(hex: "#040D14").ignoresSafeArea()
            VStack(spacing: 12) {
                Text("Profile")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Text("Coming soon")
                    .font(.system(size: 15, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.55))
                Button("Back") {
                    router.navigate(to: .home)
                }
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                )
                .buttonStyle(.plain)
                .padding(.top, 8)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    ProfilePlaceholderView()
        .environmentObject(AppRouter())
}
