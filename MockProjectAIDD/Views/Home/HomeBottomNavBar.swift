// HomeBottomNavBar.swift
// MockProjectAIDD
//
// mms_7 — Bottom Navigation Bar
// 4 tabs: SAA 2025 (house), Awards (trophy), Kudos (hands.sparkles), Profile (person)
// Active tab: white icon + label. Inactive: white/40 opacity.
// Dark background matching overall screen theme.

import SwiftUI

struct HomeBottomNavBar: View {

    // MARK: - Props
    let selectedTab: HomeTab
    let onTabTap: (HomeTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(HomeTab.allCases) { tab in
                tabItem(tab)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 60)
        .background(Color(hex: "#040D14"))
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.1))
                .frame(height: 1),
            alignment: .top
        )
    }

    @ViewBuilder
    private func tabItem(_ tab: HomeTab) -> some View {
        let isActive = tab == selectedTab

        Button {
            onTabTap(tab)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: tab.iconName)
                    .font(.system(size: 20, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color.white : Color.white.opacity(0.4))

                Text(tab.rawValue)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color.white : Color.white.opacity(0.4))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeBottomNavBar(
        selectedTab: .saa2025,
        onTabTap: { _ in }
    )
    .background(Color(hex: "#040D14"))
}
