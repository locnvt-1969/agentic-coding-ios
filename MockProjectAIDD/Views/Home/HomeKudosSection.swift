// HomeKudosSection.swift
// MockProjectAIDD
//
// mms_5 — Kudos section
// Header: "Phong trào ghi nhận" + "Sun* Kudos" title (mms_5.1)
// Banner image with KUDOS logo overlay (mms_5.2)
// "ĐIỂM MỚI CỦA SAA 2025" badge, description paragraph, "Chi tiết" button (mms_5.3)

import SwiftUI

struct HomeKudosSection: View {

    // MARK: - Props
    let description: String
    let isAvailable: Bool
    let onDetailTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.bottom, 16)

            // mms_5.1 — section header (same component as mms_4.1)
            // Figma: small label white 12pt; main title cream #FFEA9E 22pt weight 500.
            VStack(alignment: .leading, spacing: 4) {
                Text("Phong trào ghi nhận")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white)

                Text("Sun* Kudos")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color(hex: "#FFEA9E"))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // mms_5.2 — Kudos banner image (vector logo overlay anchored to right side)
            // Figma logo position: x=195/335 in container, ~22pt from right edge.
            ZStack(alignment: .trailing) {
                Color(hex: "#0A1520")
                Image("home-kudos-banner-bg")
                    .resizable()
                    .scaledToFill()

                // Sun* "S" + KUDOS wordmark logo — right-aligned to match Figma layout.
                Image("home-kudos-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 140)
                    .padding(.trailing, 22)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .clipped()
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // Badge + description + CTA
            VStack(alignment: .leading, spacing: 12) {
                // "ĐIỂM MỚI CỦA SAA 2025" badge
                Text("ĐIỂM MỚI CỦA SAA 2025")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(Color(hex: "#F4A620"))
                    .tracking(0.5)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: "#F4A620").opacity(0.15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .strokeBorder(Color(hex: "#F4A620").opacity(0.4), lineWidth: 1)
                            )
                    )

                // Description paragraph
                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .lineSpacing(5)
                    .fixedSize(horizontal: false, vertical: true)

                // mms_5.3 — Chi tiết button (primary style, same as mms_2.2)
                HomeCTAButton(title: "Chi tiết", style: .primary, action: onDetailTap)
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 20)
        .padding(.bottom, 32)
        .background(Color(hex: "#060E16"))
    }
}

#Preview {
    HomeKudosSection(
        description: HomeViewMockData.kudosDescription,
        isAvailable: true,
        onDetailTap: {}
    )
}
