// ProfileBadges.swift
// MockProjectAIDD
//
// Presentational "Bộ sưu tập icon" strip — 6 Sun* value-icon slots + owner label.
// Driven by [SunValueIcon] collected by the user. Display-only (no navigation):
// self profile shows empty circles, other-user profile shows filled icons + names.
// Design: mms_2_icon collection. Assets: rules_icon_* (Momorph/Content).

import SwiftUI

// MARK: - ProfileBadges

struct ProfileBadges: View {
    /// Value icons the user has collected (rendered left-to-right, up to 6).
    let valueIcons: [SunValueIcon]
    /// Owner name for the section label. `nil` → "của tôi" (self profile).
    var collectionOwnerName: String? = nil

    private let maxSlots = 6
    private let badgeSize: CGFloat = 44

    var body: some View {
        VStack(spacing: 12) {
            badgeRow
            sectionLabel
        }
    }

    // MARK: Badge row

    private var badgeRow: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(0..<maxSlots, id: \.self) { index in
                ProfileValueIconSlot(
                    icon: index < valueIcons.count ? valueIcons[index] : nil,
                    size: badgeSize
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Section label

    private var sectionLabel: some View {
        Text("Bộ sưu tập icon của \(collectionOwnerName ?? "tôi")")
            .font(.custom("Montserrat-Regular", size: 12))
            .foregroundStyle(Color.white)
            .multilineTextAlignment(.center)
    }
}

// MARK: - ProfileValueIconSlot

/// Single circular value-icon slot — filled (icon + name) or empty (dark placeholder).
struct ProfileValueIconSlot: View {
    let icon: SunValueIcon?
    let size: CGFloat

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.profileBadgeBg)
                    .frame(width: size, height: size)
                    .overlay(Circle().stroke(Color.profileBadgeBorder, lineWidth: 0.956))

                if let icon, UIImage(named: icon.imageName) != nil {
                    Image(icon.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                }
            }

            if let icon {
                Text(icon.label)
                    .font(.custom("Montserrat-Regular", size: 6.5))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Preview

#Preview("ProfileBadges - other (full 6)") {
    ZStack {
        Color.profileDark
        ProfileBadges(
            valueIcons: SunValueIcon.allCases,
            collectionOwnerName: "Huỳnh Dương Xuân Nhật"
        )
        .padding(.horizontal, 12)
    }
}

#Preview("ProfileBadges - self (empty)") {
    ZStack {
        Color.profileDark
        ProfileBadges(valueIcons: [])
            .padding(.horizontal, 24)
    }
}
