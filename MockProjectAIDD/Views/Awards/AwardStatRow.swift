// AwardStatRow.swift
// MockProjectAIDD
//
// Reusable stat row: icon + label header + value + unit.
// Used for "Số lượng giải thưởng" and "Giá trị giải thưởng" rows.
// Typography and spacing sourced verbatim from Figma award frames.

import SwiftUI

enum AwardStatIcon {
    case diamond // MM_MEDIA_IC Diamond
    case flag    // MM_MEDIA_IC award flag
}

struct AwardStatRow: View {
    let icon: AwardStatIcon
    let label: String
    let value: String
    let unit: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header row: icon + label
            HStack(spacing: 8) {
                iconView
                    .frame(width: 24, height: 24)

                Text(label)
                    .font(.custom("Montserrat", size: 14).weight(.bold))
                    .foregroundStyle(Color.awardGold)
                    .lineSpacing(20 - 14)
                    .tracking(0)
            }

            // Value + unit row
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.custom("Montserrat", size: 18).weight(.bold))
                    .foregroundStyle(Color.awardBodyText)
                    .tracking(0.5)

                Text(unit)
                    .font(.custom("Montserrat", size: 14).weight(.light))
                    .foregroundStyle(Color.awardBodyText)
                    .tracking(0.25)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var iconView: some View {
        switch icon {
        case .diamond:
            if UIImage(named: "ic-award-diamond") != nil {
                Image("ic-award-diamond")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
            } else {
                Image(systemName: "diamond.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
            }
        case .flag:
            if UIImage(named: "ic-award-flag") != nil {
                Image("ic-award-flag")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
            } else {
                Image(systemName: "flag.fill")
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(Color.white)
            }
        }
    }
}

#Preview {
    ZStack {
        Color.awardDark.ignoresSafeArea()
        VStack(spacing: 20) {
            AwardStatRow(icon: .diamond, label: "Số lượng giải thưởng", value: "01", unit: "Cá nhân")
            AwardStatRow(icon: .flag, label: "Giá trị giải thưởng", value: "15.000.000 VNĐ", unit: "cho giải cá nhân")
        }
        .padding(.horizontal, 20)
    }
}
