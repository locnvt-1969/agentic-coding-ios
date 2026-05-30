// AwardPageHeader.swift
// MockProjectAIDD
//
// Page header block for all award detail screens.
// Contains: eyebrow "Sun* Annual Awards 2025" label, horizontal divider,
// and the large gold title "Hệ thống giải thưởng SAA 2025".
// Figma: appears ~106pt below the scroll content start, above the type label.

import SwiftUI

struct AwardPageHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Eyebrow: "Sun* Annual Awards 2025" — 12/regular white
            Text("Sun* Annual Awards 2025")
                .font(.custom("Montserrat", size: 12).weight(.regular))
                .foregroundStyle(Color.awardBodyText)

            Rectangle()
                .fill(Color.awardDivider)
                .frame(maxWidth: .infinity, maxHeight: 1)

            // Large page title — Figma: bold ~28pt gold
            Text("Hệ thống giải thưởng\nSAA 2025")
                .font(.custom("Montserrat", size: 28).weight(.bold))
                .foregroundStyle(Color.awardGold)
                .lineSpacing(4)
                .padding(.top, 8)
        }
        .padding(.top, 106)
        .padding(.bottom, 16)
    }
}

#Preview {
    ZStack {
        Color.awardDark.ignoresSafeArea()
        AwardPageHeader()
            .padding(.horizontal, 20)
    }
}
