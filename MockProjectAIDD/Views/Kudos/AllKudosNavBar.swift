// AllKudosNavBar.swift
// MockProjectAIDD
//
// Navigation bar for the All Kudos screen.

import SwiftUI

// MARK: - AllKudosNavBar

struct AllKudosNavBar: View {
    var onBack: (() -> Void)?

    var body: some View {
        HStack(spacing: 0) {
            // Back button — 44pt tap area, 7pt leading padding from design
            Button {
                onBack?()
            } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Color.white)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .padding(.leading, 7)

            Spacer()

            Text("All Kudos")
                .font(.custom("Helvetica Neue", size: 17))
                .fontWeight(.medium)
                .foregroundStyle(Color.white)
                .kerning(0.5)

            Spacer()

            // Mirror spacer to centre title
            Color.clear
                .frame(width: 44, height: 44)
                .padding(.trailing, 7)
        }
        .frame(height: 42)
        .background(Color.clear)
    }
}
