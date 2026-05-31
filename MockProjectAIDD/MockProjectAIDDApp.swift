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
                        ErrorView(kind: kind, onPrimaryAction: { router.navigate(to: .home) })
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: router.currentRoute)
            }
            .environmentObject(router)
        }
    }
}
