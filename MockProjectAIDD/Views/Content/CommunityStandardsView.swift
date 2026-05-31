// CommunityStandardsView.swift
// MockProjectAIDD
//
// Pixel-perfect implementation of the "Tiêu chuẩn cộng đồng" screen from MoMorph Figma.
// Presentational only — accepts a CommunityStandard document and renders its sections.
//
// Layout: a normal ScrollView (content respects the top safe area) with the custom nav
// bar pinned via `.safeAreaInset(edge: .top)` and the keyvisual drawn via `.background`.
// This avoids the `.ignoresSafeArea(.top)` + scroll anti-pattern that pushes content
// off the top inside a NavigationStack.
// Screen: https://momorph.ai/files/9ypp4enmFmdK3YAFJLIu6C/screens/xms7csmDhD

import SwiftUI

struct CommunityStandardsView: View {
    let standard: CommunityStandard
    var onBack: (() -> Void)? = nil

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // KV Artboard logo (scrolls with the content)
                HStack {
                    Image("Artboard_4_2x")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 151, height: 64)
                        .clipped()
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 4)

                // Sections
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(standard.sections.enumerated()), id: \.element.id) { index, section in
                        CommunityStandardsSectionView(section: section)

                        if index < standard.sections.count - 1 {
                            Rectangle()
                                .fill(Color(hex: "2E3940"))
                                .frame(height: 1)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(alignment: .top) {
            CommunityStandardsBackgroundLayer()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            CommunityStandardsNavBar(onBack: onBack)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Background

private struct CommunityStandardsBackgroundLayer: View {
    var body: some View {
        ZStack {
            Color(hex: "00101A")
            Image("MM_MEDIA_Keyvisual_BG")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .clipped()
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "001320").opacity(0), location: 0),
                    .init(color: Color(hex: "00101A"),            location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Navigation Bar

private struct CommunityStandardsNavBar: View {
    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            // Centered title
            Text("Tiêu chuẩn chung")
                .font(.custom("Helvetica Neue", size: 17))
                .fontWeight(.medium)
                .foregroundStyle(.white)
                .tracking(0.5)
                .frame(maxWidth: .infinity, alignment: .center)

            // Leading back button
            HStack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 24)
                }
                .padding(.leading, 7)
                Spacer()
            }
        }
        .frame(height: 42)
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity)
        // Dark → transparent gradient; extends up behind the status bar for legibility.
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "00101A"),              location: 0),
                    .init(color: Color(hex: "00101A").opacity(0.3), location: 0.764),
                    .init(color: Color(hex: "00101A").opacity(0.1), location: 0.928),
                    .init(color: .clear,                            location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CommunityStandardsView(standard: .figmaSample)
    }
}
