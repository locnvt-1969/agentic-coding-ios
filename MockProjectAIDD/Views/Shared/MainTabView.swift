// MainTabView.swift
// MockProjectAIDD
//
// Main app shell after login. Bottom tab bar hosting the primary sections,
// wrapped in a NavigationStack driven by AppRouter.path for push navigation.
//
// Tab roots not yet built (Kudos, Notifications, Profile) render placeholders;
// they are replaced by real Track A views during integration (phase-19).

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var selectedTab: Tab = .home

    enum Tab: Hashable { case home, kudos, notifications, profile }

    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(Tab.home)

                TabPlaceholder(title: "Sun*Kudos")
                    .tabItem { Label("Kudos", systemImage: "hands.clap.fill") }
                    .tag(Tab.kudos)

                TabPlaceholder(title: "Notifications")
                    .tabItem { Label("Alerts", systemImage: "bell.fill") }
                    .tag(Tab.notifications)

                ProfileSelfView(
                    user: User(
                        id: "u1",
                        name: "Huỳnh Dương Xuân Nhật",
                        avatarURL: nil,
                        departmentName: "CEVC3",
                        role: "Engineer",
                        level: "Legend Hero",
                        awardTypes: [.mvp, .topTalent]
                    ),
                    awards: [
                        Award(id: "a1", type: .mvp, recipientName: "Huỳnh Dương Xuân Nhật"),
                        Award(id: "a2", type: .topTalent, recipientName: "Huỳnh Dương Xuân Nhật")
                    ],
                    onEdit: {},
                    onOpenAward: { _ in },
                    kudos: [],
                    kudosReceivedCount: 5,
                    kudosSentCount: 5,
                    onOpenSecretBox: {}
                )
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(Tab.profile)
            }
            .navigationDestination(for: NavDestination.self) { destination in
                NavDestinationView(destination: destination)
            }
        }
    }
}

/// Placeholder tab root until the real screen is integrated.
private struct TabPlaceholder: View {
    let title: String
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

/// Resolves a NavDestination to its screen. Returns placeholders until Track A
/// views are integrated (phase-19), where each case maps to its real view.
private struct NavDestinationView: View {
    let destination: NavDestination
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            Text("\(String(describing: destination))")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.6))
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppRouter())
}
