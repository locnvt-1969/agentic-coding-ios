// HomeView.swift
// MockProjectAIDD
//
// Placeholder home screen — shown after successful Google login.
// Replace with real Home screen design when available.

import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "star.fill")
                .font(.system(size: 60))
                .foregroundStyle(.yellow)

            Text("SAA 2025")
                .font(.largeTitle.bold())

            Text("Welcome to Sun* Annual Awards")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Sign Out") {
                Task {
                    await AuthService.shared.signOut()
                    router.navigate(to: .login)
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding()
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView()
        .environmentObject(AppRouter())
}
