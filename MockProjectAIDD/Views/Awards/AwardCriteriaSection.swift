// AwardCriteriaSection.swift
// MockProjectAIDD
//
// Award description + stat rows + optional extra prize row.
// Dividers match Figma: 1px #2E3940 between stat blocks.
// All typography from Figma: Montserrat 14/light body, 14/bold labels, 18/bold values.

import SwiftUI

struct AwardCriteriaSection: View {
    let type: AwardType

    private var style: AwardVariantStyle { type.variantStyle }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Award title + description block
            titleAndDescription

            divider

            // "Số lượng giải thưởng" stat
            AwardStatRow(
                icon: .diamond,
                label: "Số lượng giải thưởng",
                value: style.awardCount,
                unit: style.awardCountUnit
            )
            .padding(.vertical, 12)

            divider

            // "Giá trị giải thưởng" stat (primary)
            AwardStatRow(
                icon: .flag,
                label: "Giá trị giải thưởng",
                value: style.prizeValue,
                unit: style.prizeUnit
            )
            .padding(.top, 12)

            // Extra prize row (Signature only: individual + team split)
            if let extra = style.extraPrize {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(extra.value)
                        .font(.custom("Montserrat", size: 18).weight(.bold))
                        .foregroundStyle(Color.awardBodyText)
                        .tracking(0.5)
                    Text(extra.unit)
                        .font(.custom("Montserrat", size: 14).weight(.light))
                        .foregroundStyle(Color.awardBodyText)
                        .tracking(0.25)
                }
                .padding(.top, 4)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Subviews

    private var titleAndDescription: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Award section header: trophy icon + award title
            HStack(spacing: 8) {
                Image(systemName: "trophy.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.awardGold)

                Text(style.displayTitle)
                    .font(.custom("Montserrat", size: 14).weight(.bold))
                    .foregroundStyle(Color.awardGold)
                    .lineLimit(nil)
                    .tracking(0)
            }

            // Description body text
            Text(style.description)
                .font(.custom("Montserrat", size: 14).weight(.light))
                .foregroundStyle(Color.awardBodyText)
                .lineSpacing(6)
                .tracking(0.25)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.bottom, 12)
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.awardDivider)
            .frame(maxWidth: .infinity)
            .frame(height: 1)
    }
}

#Preview {
    ScrollView {
        AwardCriteriaSection(type: .mvp)
            .padding(.horizontal, 20)
    }
    .background(Color.awardDark)
}
