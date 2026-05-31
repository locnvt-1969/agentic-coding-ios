// HomeView.swift
// MockProjectAIDD
//
// Presentational root for the Home screen. Composes all sections in scroll order.
// Accepts all callbacks as closures — zero service calls inside.
//
// Layout strategy:
//   • Outer ZStack(alignment: .top) — full screen
//   • Background: Color(#040D14) fills entire screen including safe areas
//   • VStack: ScrollView (flexible) — bottom tab bar is owned by the MainTabView shell
//   • AwardTopNavigationBar (shared header) floats at top via an overlaying ZStack layer
//   • HomeFAB floats bottom-right above nav bar
//
// Section order (matches Figma top-to-bottom):
//   mms_1  AwardTopNavigationBar — shared floating header (overlaid, not in scroll)
//   mms_2  HomeHeroSection     — ROOT FURTHER + countdown + CTA (over keyvisual bg)
//   mms_3  HomeThemeSection    — theme description paragraph
//   mms_4  HomeAwardsSection   — horizontal award cards
//   mms_5  HomeKudosSection    — kudos banner + description
//   mms_6  HomeFAB             — floating bottom-right above nav bar
//   (mms_7 bottom tab bar lives in MainTabView, not this screen)

import SwiftUI

struct HomeView: View {

    // MARK: - Props

    let selectedLanguage: AppLanguage
    let unreadNotificationCount: Int
    let countdown: CountdownValue
    let awardsState: AwardsLoadState
    let isKudosAvailable: Bool

    // Callbacks
    let onLanguageTap: () -> Void
    let onSearchTap: () -> Void
    let onBellTap: () -> Void
    let onAboutAwardTap: () -> Void
    let onAboutKudosTap: () -> Void
    let onAwardCardTap: (String) -> Void
    let onAwardsRetry: () -> Void
    let onKudosDetailTap: () -> Void
    let onFabPencilTap: () -> Void
    let onFabSKudosTap: () -> Void

    // MARK: - Body

    var body: some View {
        ZStack(alignment: .top) {
            // Full-screen dark base (covers status bar + home indicator)
            Color(hex: "#040D14").ignoresSafeArea()

            // Main column: scrollable body (bottom tab bar provided by MainTabView shell)
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .top) {
                        // Keyvisual image anchored to top of scroll content
                        Image("home-keyvisual-bg")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 480, maxHeight: 480)
                            .clipped()
                            .frame(maxWidth: .infinity, alignment: .top)

                        // Content column laid over keyvisual
                        VStack(spacing: 0) {
                            // Clearance below the floating header (~64pt header + status bar)
                            Color.clear.frame(height: 80)

                            // mms_2 — Hero
                            HomeHeroSection(
                                countdown: countdown,
                                onAboutAwardTap: onAboutAwardTap,
                                onAboutKudosTap: onAboutKudosTap
                            )

                            // mms_3 — Theme description
                            HomeThemeSection(description: HomeViewMockData.themeDescription)

                            // mms_4 — Awards
                            HomeAwardsSection(
                                state: awardsState,
                                onAwardCardTap: onAwardCardTap,
                                onRetry: onAwardsRetry
                            )

                            // mms_5 — Kudos (gated by FeatureFlags.isKudosAvailable per TC_IOS_HOME_GUI_005)
                            if isKudosAvailable {
                                HomeKudosSection(
                                    description: HomeViewMockData.kudosDescription,
                                    isAvailable: isKudosAvailable,
                                    onDetailTap: onKudosDetailTap
                                )
                            }

                            // Bottom clearance: FAB (100pt) + nav bar (60pt) + home indicator (34pt)
                            Color.clear.frame(height: 120)
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .ignoresSafeArea(edges: .top)

            // mms_1 — Header floating at top (overlaid).
            // Uses the shared AwardTopNavigationBar (no background) so the Home & Award
            // headers are 100% in sync.
            AwardTopNavigationBar(
                onLanguage: onLanguageTap,
                onSearch: onSearchTap,
                onNotifications: onBellTap,
                language: selectedLanguage,
                unreadCount: unreadNotificationCount
            )

            // mms_6 — FAB floating bottom-right
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    HomeFAB(
                        onPencilTap: onFabPencilTap,
                        onSKudosTap: onFabSKudosTap
                    )
                    .padding(.trailing, 20)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Preview

#Preview {
    HomeView(
        selectedLanguage: .vn,
        unreadNotificationCount: 3,
        countdown: .placeholder,
        awardsState: .loaded(HomeViewMockData.awards),
        isKudosAvailable: true,
        onLanguageTap: {},
        onSearchTap: {},
        onBellTap: {},
        onAboutAwardTap: {},
        onAboutKudosTap: {},
        onAwardCardTap: { _ in },
        onAwardsRetry: {},
        onKudosDetailTap: {},
        onFabPencilTap: {},
        onFabSKudosTap: {}
    )
}
