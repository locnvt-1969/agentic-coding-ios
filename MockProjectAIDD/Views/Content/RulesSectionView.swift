// RulesSectionView.swift
// MockProjectAIDD
//
// Private subview: renders one badge row (hero tier + criteria + description).
// Used by RulesView for the 4 hero badge tiers.

import SwiftUI

// MARK: - Badge Row

struct RulesBadgeRow: View {
    let badgeImageName: String?
    let badgeLabel: String
    let criteria: String
    let description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Badge chip + criteria line
            VStack(alignment: .leading, spacing: 8) {
                if let imageName = badgeImageName {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 16)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "FFEA9E"), lineWidth: 0.421)
                        )
                } else {
                    // Fallback text chip for badges without downloadable assets
                    Text(badgeLabel)
                        .font(.custom("Montserrat", size: 9.6).weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: "2E3940"))
                        .clipShape(Capsule())
                        .overlay(
                            Capsule()
                                .stroke(Color(hex: "FFEA9E"), lineWidth: 0.421)
                        )
                }

                Text(criteria)
                    .font(.custom("Montserrat", size: 14).weight(.bold))
                    .foregroundStyle(.white)
                    .lineSpacing(6)
            }

            Text(description)
                .font(.custom("Montserrat", size: 14).weight(.regular))
                .foregroundStyle(.white)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Icon Badge Item

struct RulesIconBadgeItem: View {
    let imageName: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .overlay(
                    Circle().stroke(.white, lineWidth: 1)
                )

            Text(label)
                .font(.custom("Montserrat", size: 10).weight(.regular))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineLimit(3)
                .minimumScaleFactor(0.8)
        }
    }
}
