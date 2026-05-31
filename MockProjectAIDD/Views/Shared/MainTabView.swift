// MainTabView.swift
// MockProjectAIDD
//
// Main app shell after login. Bottom tab bar hosting the primary sections,
// wrapped in a NavigationStack driven by AppRouter.path for push navigation.

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

                KudosBoardContainer()
                    .tabItem { Label("Kudos", systemImage: "hands.clap.fill") }
                    .tag(Tab.kudos)

                NotificationsContainer()
                    .tabItem { Label("Alerts", systemImage: "bell.fill") }
                    .tag(Tab.notifications)

                ProfileSelfContainer()
                    .tabItem { Label("Profile", systemImage: "person.fill") }
                    .tag(Tab.profile)
            }
            .navigationDestination(for: NavDestination.self) { destination in
                NavDestinationResolver(destination: destination)
            }
        }
    }
}

/// Resolves a NavDestination to its real container screen.
private struct NavDestinationResolver: View {
    let destination: NavDestination

    var body: some View {
        switch destination {
        case .profileSelf:
            ProfileSelfContainer()
        case .profileOther(let userId):
            ProfileOtherContainer(userId: userId)
        case .awardDetail(let type):
            AwardDetailContainer(type: type)
        case .secretBox:
            SecretBoxContainer()
        case .kudosBoard:
            KudosBoardContainer()
        case .allKudos:
            AllKudosContainer()
        case .sendKudo:
            SendKudoContainer()
        case .viewKudo(let id):
            ViewKudoContainer(kudoId: id)
        case .searchSunner:
            SearchSunnerContainer()
        case .communityStandards:
            CommunityStandardsContainer()
        case .rules:
            RulesContainer()
        case .notifications:
            NotificationsContainer()
        }
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppRouter())
}
