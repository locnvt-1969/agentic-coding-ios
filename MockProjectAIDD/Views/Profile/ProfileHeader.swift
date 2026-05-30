// ProfileHeader.swift
// MockProjectAIDD
// Presentational header: keyvisual BG + avatar + name + department + level badge.
// Reusable by phase-09. Design: mms_1.1_member. Colors: Color+ProfileTokens.

import SwiftUI

// MARK: - ProfileHeader

struct ProfileHeader: View {
    let user: User

    var body: some View {
        ZStack(alignment: .bottom) {
            ProfileKeyvisualBackground()
            VStack(spacing: 24) {
                ProfileAvatarView(avatarURL: user.avatarURL)
                ProfileNameBlock(user: user)
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 288)
    }
}

// MARK: - ProfileKeyvisualBackground

private struct ProfileKeyvisualBackground: View {
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep dark base
                Color.profileDark
                // Keyvisual BG image — right side, partially visible
                Image("profile_keyvisual_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                // Left shadow gradient overlay
                HStack(spacing: 0) {
                    LinearGradient(
                        colors: [Color(hex: "00101A"), Color(hex: "10181F"), Color(hex: "00101A").opacity(0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: min(geo.size.width * 0.6, 220))
                    Spacer()
                }
                // Bottom shadow gradient overlay
                VStack(spacing: 0) {
                    Spacer()
                    LinearGradient(
                        colors: [Color(hex: "00101A"), Color(hex: "00101A").opacity(0)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                    .frame(height: 80)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
}

// MARK: - ProfileAvatarView

private struct ProfileAvatarView: View {
    let avatarURL: URL?

    var body: some View {
        Group {
            if let url = avatarURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        avatarPlaceholder
                    default:
                        avatarPlaceholder
                    }
                }
            } else {
                avatarPlaceholder
            }
        }
        .frame(width: 72, height: 72)
        .clipShape(Circle())
        .overlay(Circle().stroke(Color.white, lineWidth: 1.911))
    }

    private var avatarPlaceholder: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .foregroundStyle(Color(hex: "999999"))
    }
}

// MARK: - ProfileNameBlock

private struct ProfileNameBlock: View {
    let user: User

    var body: some View {
        VStack(spacing: 4) {
            // Name — Montserrat Bold 18/24 #FFEA9E
            Text(user.name)
                .font(.custom("Montserrat-Bold", size: 18))
                .foregroundStyle(Color.profileNameHighlight)
                .lineLimit(1)

            // Department + dot + level badge row
            HStack(spacing: 4.78) {
                if let dept = user.departmentName {
                    Text(dept)
                        .font(.custom("Montserrat-Regular", size: 14))
                        .foregroundStyle(Color.white)
                        .tracking(0.25)
                }
                if user.departmentName != nil && user.level != nil {
                    Circle()
                        .fill(Color(hex: "999999").opacity(0.4))
                        .frame(width: 2, height: 2)
                }
                if let level = user.level {
                    ProfileLevelBadge(title: level)
                }
            }
        }
    }
}

// MARK: - ProfileLevelBadge

/// Small pill badge showing title/danh hiệu (e.g. "Legend Hero").
/// Reusable by phase-09.
struct ProfileLevelBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.custom("Montserrat-Bold", size: 7.9))
            .foregroundStyle(Color.white)
            .shadow(color: .white, radius: 0.4)
            .tracking(0.057)
            .lineLimit(1)
            .padding(.horizontal, 4)
            .padding(.vertical, 2)
            .background(Color.black.opacity(0.4))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.profileNameHighlight, lineWidth: 0.309))
    }
}

// MARK: - Preview

#Preview("ProfileHeader - with avatar") {
    ProfileHeader(
        user: User(
            id: "u1",
            name: "Huỳnh Dương Xuân Nhật",
            avatarURL: nil,
            departmentName: "CEVC3",
            role: "Engineer",
            level: "Legend Hero",
            awardTypes: [.mvp, .topTalent]
        )
    )
    .background(Color.profileDark)
}

#Preview("ProfileHeader - no level") {
    ProfileHeader(
        user: User(
            id: "u2",
            name: "Dương Xuân Huỳnh",
            departmentName: "CEVC10",
            role: nil,
            level: nil
        )
    )
    .background(Color.profileDark)
}
