// KudosHeroSection.swift
// MockProjectAIDD
//
// KUDOS hero header — displayed below the top nav bar, above AwardPageHeader.
// MoMorph node: mms_A_KV Kudos (6885:10266)
// Screen: [iOS] Award_Top talent (fileKey: 9ypp4enmFmdK3YAFJLIu6C, screenId: c-QM3_zjkG)
//
// Design layout (coords relative to content frame, x=20):
//   y=144: "Hệ thống ghi nhận và cảm ơn" text (14px Montserrat Medium, color=#FFEA9E)
//   y=172: kudo logo row — SVG logo (49×38) + KUDOS wordmark group (163×39)
// Total section: width=221, height=67

import SwiftUI

struct KudosHeroSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            eyebrowText
            kudoLogoRow
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - "Hệ thống ghi nhận và cảm ơn"
    // Design: fontSize=14, fontFamily=Montserrat, fontWeight=500, color=#FFEA9E
    private var eyebrowText: some View {
        Text("Hệ thống ghi nhận và cảm ơn")
            .font(.custom("Montserrat", size: 14).weight(.medium))
            .foregroundStyle(Color.awardGold)
            .lineLimit(1)
    }

    // MARK: - Logo row: star-flame logo + KUDOS wordmark
    // Design: HStack gap=9, width=221, height=39, justifyContent=space-between
    private var kudoLogoRow: some View {
        HStack(spacing: 9) {
            // Left: kudos-hero-logo SVG (49×38) — mm_media_logo group node 6885:10271
            Image("kudos-hero-logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 49, height: 38)

            // Right: KUDOS wordmark text group (163×39)
            // The KUDOS group 6885:10277 is a text-art group; render as styled text.
            // Design from node 6885:10322 inside Logo/Kudos: font SVN-Gotham, ~28px, color=#DBD1C1
            // We match with a visually similar bold serif text at the right scale.
            KudosWordmark()
                .frame(width: 163, height: 39)

            Spacer(minLength: 0)
        }
    }
}

// MARK: - KUDOS wordmark
// Design reference: node 6885:10322 — fontFamily="SVN-Gotham", fontSize≈28, color=#DBD1C1
// SVN-Gotham is a licensed font not bundled with iOS; fall back to system heavy serif
// that visually approximates the design weight/style.
private struct KudosWordmark: View {
    var body: some View {
        Text("KUDOS")
            .font(.custom("Montserrat", size: 30).weight(.heavy))
            .foregroundStyle(Color(hex: "DBD1C1"))
            .kerning(-2)
            .minimumScaleFactor(0.8)
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "00101A").ignoresSafeArea()
        KudosHeroSection()
            .padding(.horizontal, 20)
    }
    .frame(height: 100)
}
