// HomeContainerView.swift
// MockProjectAIDD
//
// Wires HomeViewModel into the presentational HomeView.
// Owns the language sheet and lifecycle hooks.

import SwiftUI

struct HomeContainerView: View {
    @State private var viewModel = HomeViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        HomeView(
            selectedLanguage: viewModel.selectedLanguage,
            unreadNotificationCount: viewModel.unreadNotificationCount,
            countdown: viewModel.countdown,
            awardsState: viewModel.awardsState,
            isKudosAvailable: viewModel.isKudosAvailable,
            onLanguageTap:    { viewModel.languageTapped() },
            onSearchTap:      { viewModel.searchTapped(router: router) },
            onBellTap:        { viewModel.bellTapped(router: router) },
            onAboutAwardTap:  { viewModel.aboutAwardTapped(router: router) },
            onAboutKudosTap:  { viewModel.aboutKudosTapped(router: router) },
            onAwardCardTap:   { viewModel.awardCardTapped($0, router: router) },
            onAwardsRetry:    { viewModel.retryAwards() },
            onKudosDetailTap: { viewModel.kudosDetailTapped(router: router) },
            onFabPencilTap:   { viewModel.fabPencilTapped(router: router) },
            onFabSKudosTap:   { viewModel.fabSKudosTapped(router: router) }
        )
        .onAppear { viewModel.onAppear() }
        .onDisappear { viewModel.onDisappear() }
        .sheet(isPresented: $viewModel.isLanguageSheetPresented) {
            LanguageSheetView(
                selectedLanguage: viewModel.selectedLanguage,
                onSelect: { viewModel.selectLanguage($0) },
                onDismiss: { viewModel.isLanguageSheetPresented = false }
            )
            .presentationDetents([.height(200)])
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - Inline language sheet (avoids LanguageDropdownView API mismatch in sheet context)

private struct LanguageSheetView: View {
    let selectedLanguage: AppLanguage
    let onSelect: (AppLanguage) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack {
            Color(hex: "#0D1B2A").ignoresSafeArea()
            VStack(spacing: 0) {
                Text("Ngôn ngữ / Language")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 16)

                Divider().background(Color.white.opacity(0.12))

                ForEach(AppLanguage.allCases) { lang in
                    Button {
                        onSelect(lang)
                    } label: {
                        HStack(spacing: 12) {
                            Text(lang.flagEmoji).font(.system(size: 20))
                            Text(lang.displayCode)
                                .font(.system(size: 15, weight: .medium))
                                .foregroundStyle(.white)
                            Spacer()
                            if lang == selectedLanguage {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundStyle(.white)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 14)
                        .background(
                            lang == selectedLanguage
                                ? Color.white.opacity(0.1)
                                : Color.clear
                        )
                    }
                    .buttonStyle(.plain)

                    Divider().background(Color.white.opacity(0.08))
                }
            }
        }
    }
}

#Preview {
    HomeContainerView()
        .environmentObject(AppRouter())
}
