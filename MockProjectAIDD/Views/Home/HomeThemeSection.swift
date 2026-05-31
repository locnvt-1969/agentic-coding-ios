// HomeThemeSection.swift
// MockProjectAIDD
//
// mms_3 — Theme description paragraph about "Root Further"
// Dark background, white body text, verbatim from Figma design.

import SwiftUI

struct HomeThemeSection: View {

    // MARK: - Props
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(description)
                .font(.system(size: 13, weight: .regular))
                .foregroundStyle(Color.white.opacity(0.85))
                .lineSpacing(5)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "#060E16"))
    }
}

#Preview {
    HomeThemeSection(description: HomeViewMockData.themeDescription)
}
