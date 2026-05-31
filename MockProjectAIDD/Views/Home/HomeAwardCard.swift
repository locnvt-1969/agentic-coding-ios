// HomeAwardCard.swift
// MockProjectAIDD
//
// mms_4.2 — Single award card used in the horizontal scroll list.
// Dark card with thumbnail (home-award-card-bg), name, truncated description, "Chi tiết" link.

import SwiftUI

struct HomeAwardCard: View {

    // MARK: - Props
    let award: AwardItem
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Thumbnail — shared BG with award name burned in via SwiftUI overlay.
            // (Figma uses per-award styled PNGs; only Top Talent's full composite ships
            // cleanly through MoMorph export, so we approximate with a cream text overlay
            // for uniformity across all 3 awards.)
            ZStack {
                Color(hex: "#0D1B2A")
                Image(award.thumbnailName)
                    .resizable()
                    .scaledToFill()
                    .clipped()

                Text(award.name.uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .tracking(1)
                    .foregroundStyle(Color(hex: "#FFEA9E"))
                    .shadow(color: .black.opacity(0.5), radius: 4, x: 0, y: 1)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .frame(width: 160, height: 160)
            .clipped()
            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            // Award name + description + Chi tiết link
            // Figma: name cream #FFEA9E 14pt weight 500; description white 14pt weight 300;
            // Chi tiết button text white 14pt weight 500.
            VStack(alignment: .leading, spacing: 2) {
                Text(award.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(Color(hex: "#FFEA9E"))
                    .lineLimit(1)

                Text(award.description)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(.white)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Button(action: onTap) {
                HStack(spacing: 4) {
                    Text("Chi tiết")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(.white)
                    Image(systemName: "arrow.up.right")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .buttonStyle(.plain)
        }
        .frame(width: 160, alignment: .leading)
    }
}

#Preview {
    HomeAwardCard(
        award: HomeViewMockData.awards[0],
        onTap: {}
    )
    .padding()
    .background(Color(hex: "#060E16"))
}
