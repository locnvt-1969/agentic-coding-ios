// AwardHeroSection.swift
// MockProjectAIDD
//
// Renders the award medallion — gold ring + pedestal + wordmark — as a
// single pre-composed image extracted from Figma (160×160 rounded square).
// Falls back to the old bg + wordmark composite when the medallion asset
// is missing (e.g. during development before assets are synced).

import SwiftUI

struct AwardHeroSection: View {
    let type: AwardType

    var body: some View {
        Group {
            if UIImage(named: type.medallionAsset) != nil {
                medallionImage
            } else {
                fallbackComposite
            }
        }
        // Drop shadow matching Figma: 0 1.905px 1.905px rgba(0,0,0,0.25)
        .shadow(color: Color.black.opacity(0.25), radius: 0.95, x: 0, y: 1.9)
        // Outer glow: 0 0 2.857px #FAE287
        .shadow(color: Color.awardHeroGlow.opacity(0.8), radius: 2.86, x: 0, y: 0)
    }

    // MARK: - Single full-composite medallion (preferred path)

    private var medallionImage: some View {
        Image(type.medallionAsset)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 160, height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 11.43))
            // The extracted image already contains the glow ring so no
            // additional stroke overlay is needed here.
    }

    // MARK: - Fallback: bg + wordmark composite (legacy, kept for safety)

    private var fallbackComposite: some View {
        ZStack {
            if let bgImage = UIImage(named: "award_medallion_bg") {
                Image(uiImage: bgImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 11.43))
            } else {
                RoundedRectangle(cornerRadius: 11.43)
                    .fill(Color.awardHeroBg)
                    .frame(width: 160, height: 160)
            }

            fallbackWordmark
                .frame(maxWidth: 105, maxHeight: 30)

            RoundedRectangle(cornerRadius: 11.43)
                .stroke(Color.awardHeroGlow.opacity(0.8), lineWidth: 2.86)
                .blendMode(.screen)
        }
        .frame(width: 160, height: 160)
        .overlay(
            RoundedRectangle(cornerRadius: 11.43)
                .stroke(Color.awardGold, lineWidth: 0.46)
        )
    }

    @ViewBuilder
    private var fallbackWordmark: some View {
        let iconName = "\(type.assetFolder)_icon"
        if UIImage(named: iconName) != nil {
            Image(iconName)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
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
            AwardHeroSection(type: .bestManager)
        }
    }
}
