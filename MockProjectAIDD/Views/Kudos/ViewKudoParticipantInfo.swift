// ViewKudoParticipantInfo.swift
// MockProjectAIDD
//
// Single participant column (avatar + name + sub-label) used in the kudo detail card.
// Anonymity: caller passes kudo.resolvedSender (nil when anonymous).
// When user is nil, masked avatar + anonymousDisplayName/anonymousSubLabel are shown.

import SwiftUI

// MARK: - ViewKudoParticipantInfo

struct ViewKudoParticipantInfo: View {
    let user: User?
    /// Display name when user is anonymous
    let anonymousDisplayName: String?
    /// Sub-label shown instead of department when anonymous
    let anonymousSubLabel: String?
    let isSender: Bool
    let textAlignment: HorizontalAlignment

    private var displayName: String {
        user?.name ?? anonymousDisplayName ?? "Unknown"
    }

    private var subLabel: String {
        // When user is nil (anonymous sender), use the anonymous sub-label.
        // Otherwise show department. Badge comes from level field.
        if user == nil, let sub = anonymousSubLabel { return sub }
        return user?.departmentName ?? user?.level ?? ""
    }

    var body: some View {
        VStack(alignment: textAlignment, spacing: 8) {
            // Avatar — 24×24, circular, white 0.865pt border
            ZStack {
                Circle()
                    .fill(Color(hex: "EEEEEE"))
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.white, lineWidth: 0.865))

                if let url = user?.avatarURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let img):
                            img.resizable().scaledToFill()
                        default:
                            Color(hex: "EEEEEE")
                        }
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 0.865))
                } else {
                    // Anonymous or no avatar — masked person icon
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.kudosMuted)
                }
            }
            .frame(width: 24, height: 24)

            // Name + sub-label
            VStack(alignment: .leading, spacing: 4) {
                // Figma: Montserrat 10pt Regular, #00101A, left aligned, lineLimit 1
                Text(displayName)
                    .font(.custom("Montserrat", size: 10))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosDark)
                    .lineLimit(1)
                    .frame(width: 109, alignment: .leading)

                // Sub-label: department/badge or anonymous label
                if !subLabel.isEmpty {
                    Text(subLabel)
                        .font(.custom("Montserrat", size: 10))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.kudosMuted)
                        .lineLimit(1)
                        .frame(maxWidth: 109, alignment: .leading)
                }
            }
        }
        .frame(width: 109, height: 62)
    }
}
