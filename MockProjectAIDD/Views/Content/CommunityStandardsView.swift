// CommunityStandardsView.swift
// MockProjectAIDD
//
// Pixel-perfect implementation of the "Tiêu chuẩn cộng đồng" screen from MoMorph Figma.
// Presentational only — accepts a CommunityStandard document and renders its sections.
// Screen: https://momorph.ai/files/9ypp4enmFmdK3YAFJLIu6C/screens/xms7csmDhD

import SwiftUI

struct CommunityStandardsView: View {
    let standard: CommunityStandard
    var onBack: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            // Full-screen dark background base
            Color(hex: "00101A")
                .ignoresSafeArea()

            // Background keyvisual image (decorative, aligned left)
            Image("MM_MEDIA_Keyvisual_BG")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .ignoresSafeArea()
                .allowsHitTesting(false)

            // Dark gradient overlay over the bg (bottom-anchored)
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "001320").opacity(0), location: 0),
                    .init(color: Color(hex: "00101A"),             location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)

            VStack(spacing: 0) {
                // ── TopNavigation ──────────────────────────────────────
                CommunityStandardsNavBar(onBack: onBack)

                // ── KV Artboard logo ──────────────────────────────────
                HStack {
                    Image("Artboard_4_2x")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 151, height: 64)
                        .clipped()
                    Spacer()
                }
                .padding(.horizontal, 20)
                .frame(height: 64)

                // ── Scrollable content ────────────────────────────────
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(standard.sections.enumerated()), id: \.element.id) { index, section in
                            CommunityStandardsSectionView(section: section)

                            if index < standard.sections.count - 1 {
                                Rectangle()
                                    .fill(Color(hex: "2E3940"))
                                    .frame(height: 1)
                                    .padding(.leading, 0)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                }
            }

            // Top navigation gradient overlay (dark → transparent)
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "00101A"),             location: 0),
                    .init(color: Color(hex: "00101A").opacity(0.3), location: 0.764),
                    .init(color: Color(hex: "00101A").opacity(0.2), location: 0.846),
                    .init(color: Color(hex: "00101A").opacity(0.15),location: 0.887),
                    .init(color: Color(hex: "00101A").opacity(0.1), location: 0.928),
                    .init(color: Color(hex: "00101A").opacity(0.05),location: 0.964),
                    .init(color: .clear,                            location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 89)
            .frame(maxWidth: .infinity, alignment: .top)
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Navigation Bar

private struct CommunityStandardsNavBar: View {
    var onBack: (() -> Void)?

    var body: some View {
        VStack(spacing: 0) {
            // Status bar spacer (47pt per Figma)
            Color.clear.frame(height: 47)

            // Nav content row
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
        }
        .frame(height: 89)
    }
}

// MARK: - Preview

#Preview {
    CommunityStandardsView(standard: .figmaSample)
}
