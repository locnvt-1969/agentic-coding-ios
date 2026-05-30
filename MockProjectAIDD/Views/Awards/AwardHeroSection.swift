// AwardHeroSection.swift
// MockProjectAIDD
//
// Hero medallion + award name image — 160×160 rounded square with
// gold border and glow, sourced from Figma award frames (phase-10).

import SwiftUI

struct AwardHeroSection: View {
    let type: AwardType

    var body: some View {
        ZStack {
            // Background medallion glow — shared across all 6 award variants
            if let bgImage = UIImage(named: "award_medallion_bg") {
                Image(uiImage: bgImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 11.43))
            } else {
                // Fallback: dark rounded rectangle with gold border
                RoundedRectangle(cornerRadius: 11.43)
                    .fill(Color.awardHeroBg)
                    .frame(width: 160, height: 160)
            }

            // Award name text-art image (per-variant, e.g. "MM_MEDIA_MVP")
            awardNameImage
                .frame(maxWidth: 105, maxHeight: 30)

            // Glow stroke layer — blendMode scoped here only (not the whole ZStack)
            RoundedRectangle(cornerRadius: 11.43)
                .stroke(Color.awardHeroGlow.opacity(0.8), lineWidth: 2.86)
                .blendMode(.screen)
        }
        .frame(width: 160, height: 160)
        .overlay(
            RoundedRectangle(cornerRadius: 11.43)
                .stroke(Color.awardGold, lineWidth: 0.46)
        )
        // Drop shadow matching Figma: box-shadow 0 1.9px 1.9px rgba(0,0,0,0.25)
        .shadow(color: Color.black.opacity(0.25), radius: 0.95, x: 0, y: 1.9)
        // Outer glow shadow: 0 0 2.86px #FAE287
        .shadow(color: Color.awardHeroGlow.opacity(0.8), radius: 2.86, x: 0, y: 0)
    }

    // MARK: - Per-variant award name art

    @ViewBuilder
    private var awardNameImage: some View {
        let iconName = "\(type.assetFolder)_icon"
        if UIImage(named: iconName) != nil {
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            // Fallback text if image not yet available
            Text(type.title)
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.awardGold)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    ZStack {
        Color.awardDark.ignoresSafeArea()
        VStack(spacing: 24) {
            AwardHeroSection(type: .mvp)
            AwardHeroSection(type: .topTalent)
        }
    }
}
