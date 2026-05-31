// SpotlightBoardSection.swift
// MockProjectAIDD
//
// Presentational sub-view for the Spotlight Board (B.6 / B.7).
// Shows: section header, "388 KUDOS" label, static spotlight chart image,
// and a non-functional styled search bar (placeholder "Tìm kiếm", per TC_IOS_KUDOS_GUI_009).
// Design source: MoMorph fO0Kt19sZZ, node 6885:9099 / 6885:9101.

import SwiftUI

struct SpotlightBoardSection: View {
    let totalKudos: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            KudosSectionHeader(
                title: "SPOTLIGHT BOARD",
                subtitle: "Sun* Annual Awards 2025"
            )

            spotlightCard
        }
    }

    // MARK: - Spotlight card (B.7)

    private var spotlightCard: some View {
        ZStack(alignment: .topLeading) {
            // Chart canvas fills the card
            Image("SpotlightChart")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 159)
                .clipped()

            // Overlay: KUDOS count + search bar
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    searchBar
                    Spacer()
                    Text("\(totalKudos) KUDOS")
                        .font(.custom("Montserrat", size: 10.5))
                        .fontWeight(.regular)
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 8)
                .padding(.top, 8)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 159)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.kudosBorderMuted, lineWidth: 0.29)
        )
        .padding(.horizontal, 20)
    }

    // MARK: - Search bar (B.7.3) — purely visual, no binding

    private var searchBar: some View {
        HStack(spacing: 3) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 5))
                .foregroundStyle(Color.white)
            Text("Tìm kiếm")
                .font(.custom("Montserrat", size: 3.2))
                .fontWeight(.medium)
                .foregroundStyle(Color.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 3.2)
        .padding(.vertical, 4.8)
        .background(Color.kudosAccent.opacity(0.10))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.kudosBorderMuted, lineWidth: 0.2)
        )
    }
}

// MARK: - Preview

#Preview("SpotlightBoardSection") {
    ScrollView {
        SpotlightBoardSection(totalKudos: 388)
            .padding(.vertical, 16)
    }
    .background(Color(hex: "00101A"))
}
