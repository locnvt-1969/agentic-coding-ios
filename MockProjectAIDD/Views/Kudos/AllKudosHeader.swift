// AllKudosHeader.swift
// MockProjectAIDD
//
// Header section for the All Kudos screen (subtitle + divider + title).

import SwiftUI

// MARK: - AllKudosHeader

struct AllKudosHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Subtitle: "Sun* Annual Awards 2025"
            Text("Sun* Annual Awards 2025")
                .font(.custom("Montserrat", size: 12))
                .fontWeight(.regular)
                .foregroundStyle(Color.white)

            // Divider — rgba(46,57,64,1) per design
            Rectangle()
                .fill(Color(hex: "2E3940"))
                .frame(maxWidth: .infinity)
                .frame(height: 1)

            // Title: "ALL KUDOS"
            Text("ALL KUDOS")
                .font(.custom("Montserrat", size: 22))
                .fontWeight(.medium)
                .foregroundStyle(Color.kudosAccent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 0)
        .padding(.bottom, 12)
    }
}
