// MainTabView.swift
// MockProjectAIDD
//
// Main app shell after login. Bottom tab bar hosting the primary sections,
// wrapped in a NavigationStack driven by AppRouter.path for push navigation.

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: AppRouter
    @State private var selectedTab: Tab = .home

    // Bottom tabs per Figma [iOS] navigation bar: SAA 2025 · Awards · Kudos · Profile.
    // Notifications is NOT a tab — it lives in the top navigation bell.
    enum Tab: Hashable { case home, awards, kudos, profile }

    var body: some View {
        NavigationStack(path: $router.path) {
            TabView(selection: $selectedTab) {
                HomeContainerView()
                    .tabItem { Label("SAA 2025", image: "tab-home") }
                    .tag(Tab.home)

                AwardDetailContainer()
                    .tabItem { Label("Awards", image: "tab-award") }
                    .tag(Tab.awards)

                KudosBoardContainer()
                    .tabItem { Label("Kudos", image: "tab-kudos") }
                    .tag(Tab.kudos)

                ProfileSelfContainer()
                    .tabItem { Label("Profile", image: "tab-profile") }
                    .tag(Tab.profile)
            }
            .tint(Color.awardGold)
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
            AwardDetailContainer(initialType: type, showsBack: true)
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
