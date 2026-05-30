// ProfileBadges.swift
// MockProjectAIDD
//
// Presentational badges/huy-hiệu strip — "Bộ sưu tập icon của tôi".
// Driven by [AwardType] from User. Reusable by phase-09.
// Design: mms_2_icon collection — 6 circular badge slots, label below.

import SwiftUI

// MARK: - ProfileBadges

struct ProfileBadges: View {
    /// Award types the user has earned (up to 6 shown).
    let awardTypes: [AwardType]
    /// Called when user taps a badge slot that has an award.
    var onOpenAward: (AwardType) -> Void = { _ in }

    private let maxSlots = 6
    private let badgeSize: CGFloat = 32
    private let badgeSpacing: CGFloat = 14

    var body: some View {
        VStack(spacing: 12) {
            badgeRow
            sectionLabel
        }
    }

    // MARK: Badge row

    private var badgeRow: some View {
        HStack(spacing: badgeSpacing) {
            ForEach(0..<maxSlots, id: \.self) { index in
                if index < awardTypes.count {
                    let awardType = awardTypes[index]
                    ProfileBadgeSlot(awardType: awardType, size: badgeSize) {
                        onOpenAward(awardType)
                    }
                } else {
                    ProfileBadgeSlot(awardType: nil, size: badgeSize)
                }
            }
        }
    }

    // MARK: Section label

    private var sectionLabel: some View {
        Text("Bộ sưu tập icon của tôi")
            .font(.custom("Montserrat-Regular", size: 12))
            .foregroundStyle(Color.white)
            .multilineTextAlignment(.center)
    }
}

// MARK: - ProfileBadgeSlot

/// Single circular badge — filled (with award icon) or empty (dark placeholder).
struct ProfileBadgeSlot: View {
    let awardType: AwardType?
    let size: CGFloat
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            ZStack {
                Circle()
                    .fill(Color.profileBadgeBg)
                    .frame(width: size, height: size)
                    .overlay(
                        Circle().stroke(Color.profileBadgeBorder, lineWidth: 0.956)
                    )

                if let awardType {
                    awardIcon(for: awardType)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.75, height: size * 0.75)
                        .clipShape(Circle())
                }
            }
        }
        .buttonStyle(.plain)
        .disabled(awardType == nil)
    }

    private func awardIcon(for type: AwardType) -> Image {
        // Asset name pattern: "<AwardFolder>_icon" under Assets.xcassets/Momorph/Awards/.
        // Phase-10 adds these assets; until then fall back to an SF Symbol so the
        // slot is never an invisible blank.
        let assetName = "\(type.assetFolder)_icon"
        if UIImage(named: assetName) != nil { return Image(assetName) }
        return Image(systemName: "rosette")
    }
}

// MARK: - Preview

#Preview("ProfileBadges - 2 awards") {
    ZStack {
        Color.profileDark
        ProfileBadges(
            awardTypes: [.mvp, .topTalent],
            onOpenAward: { _ in }
        )
        .padding()
    }
}

#Preview("ProfileBadges - full (6 awards)") {
    ZStack {
        Color.profileDark
        ProfileBadges(
            awardTypes: AwardType.allCases,
            onOpenAward: { _ in }
        )
        .padding()
    }
}

#Preview("ProfileBadges - empty") {
    ZStack {
        Color.profileDark
        ProfileBadges(awardTypes: [])
            .padding()
    }
}
