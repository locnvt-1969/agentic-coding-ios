// MockProjectAIDDApp.swift
// MockProjectAIDD

import SwiftUI

@main
struct MockProjectAIDDApp: App {
    @StateObject private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // App-level background ensures no white system background bleeds
                // through any safe area (status bar, home indicator, etc.)
                Color.black.ignoresSafeArea()

                Group {
                    switch router.currentRoute {
                    case .login:
                        LoginContainerView()
                    case .home:
                        MainTabView()
                    case .error(let kind):
                        ErrorRouteView(kind: kind)
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: router.currentRoute)
            }
            .environmentObject(router)
        }
    }
}

/// Temporary full-screen error host. Replaced by the real Access denied / Not Found
/// views in Track A (phase-05). Kept inline so the app compiles before those land.
private struct ErrorRouteView: View {
    let kind: AppErrorKind
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        VStack(spacing: 16) {
            Text(kind == .accessDenied ? "403" : "404")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(.white)
            Text(kind == .accessDenied ? "Access denied" : "Not found")
                .foregroundStyle(.white.opacity(0.7))
            Button("Back to Home") { router.navigate(to: .home) }
                .buttonStyle(.borderedProminent)
        }
    }
}
