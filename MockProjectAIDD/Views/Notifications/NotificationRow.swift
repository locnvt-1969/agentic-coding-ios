// NotificationRow.swift
// MockProjectAIDD
//
// Single notification row — presentational only.
// Design: Figma [iOS] Notifications / mms_B.1_Noti (7 types, each with its own icon/color).
// Layout: 8pt padding, icon 24×24 pinned top, content block, optional unread dot.
// Unread: message weight 700, red dot 8×8 trailing-top. Read: weight 400, no dot.
// contentHidden type also shows an inline "Tiêu chuẩn cộng đồng →" link.
// Icons are SF Symbol approximations; colors follow the spec text.

import SwiftUI

struct NotificationRow: View {
    let item: AppNotification
    let onTap: (AppNotification) -> Void
    var onCommunityStandards: (() -> Void)? = nil
    var showsDivider: Bool = true

    // Static formatter — one instance for all rows.
    private static let relativeFormatter: RelativeDateTimeFormatter = {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .full
        f.locale = Locale(identifier: "vi_VN")
        return f
    }()

    var body: some View {
        Button(action: { onTap(item) }) {
            HStack(alignment: .top, spacing: 16) {
                kindIcon
                contentBlock
                if !item.isRead {
                    unreadDot
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(Color(hex: "#2E3940"))
                    .frame(height: 1)
            }
        }
    }

    // MARK: - Kind icon (24×24 SF Symbol, pinned top)

    private var kindIcon: some View {
        Image(systemName: item.kind.systemImageName)
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
            .foregroundStyle(item.kind.iconColor)
    }

    // MARK: - Content: message + optional link + timestamp

    private var contentBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.message)
                .font(.custom("Montserrat", size: 14)
                    .weight(item.isRead ? .regular : .bold))
                .foregroundStyle(.white)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            // Inline community-standards link (contentHidden type only)
            if item.kind == .contentHidden {
                Button(action: { onCommunityStandards?() }) {
                    HStack(spacing: 4) {
                        Text("Tiêu chuẩn cộng đồng")
                            .font(.custom("Montserrat", size: 14).weight(.medium))
                            .underline()
                        Image(systemName: "arrow.up.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }

            Text(Self.relativeFormatter.localizedString(for: item.createdAt, relativeTo: Date()))
                .font(.custom("Montserrat", size: 12).weight(.regular))
                .foregroundStyle(Color(hex: "#999999"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Unread indicator dot (8×8 red circle, trailing-top)

    private var unreadDot: some View {
        Circle()
            .fill(Color(hex: "#D4271D"))
            .frame(width: 8, height: 8)
            .padding(.top, 4)
    }
}

// MARK: - Kind helpers (icons = SF Symbol approximations; colors per spec text)

private extension AppNotification.Kind {
    var systemImageName: String {
        switch self {
        case .kudoReceived:   return "envelope.fill"
        case .kudoReaction:   return "heart.fill"
        case .secretBox:      return "gift.fill"
        case .levelUp:        return "star.fill"
        case .contentHidden:  return "exclamationmark.triangle.fill"
        case .badgeCollected: return "checkmark.seal.fill"
        case .reviewRequest:  return "square.and.pencil"
        }
    }

    var iconColor: Color {
        switch self {
        case .kudoReceived:   return Color(hex: "#4A9EE0")  // blue envelope
        case .kudoReaction:   return Color(hex: "#E05E7A")  // pink heart
        case .secretBox:      return Color(hex: "#5BBF6A")  // green gift
        case .levelUp:        return Color(hex: "#E8C84A")  // yellow star
        case .contentHidden:  return Color(hex: "#E8A44A")  // amber warning
        case .badgeCollected: return Color(hex: "#4A9EE0")  // blue shield
        case .reviewRequest:  return Color(hex: "#9B6BD6")  // purple pen
        }
    }
}

// MARK: - Preview

#Preview("All 7 types") {
    ScrollView {
        VStack(spacing: 0) {
            ForEach(Array(NotificationsPreviewData.figmaSamples.enumerated()), id: \.element.id) { i, item in
                NotificationRow(
                    item: item,
                    onTap: { _ in },
                    onCommunityStandards: {},
                    showsDivider: i < NotificationsPreviewData.figmaSamples.count - 1
                )
            }
        }
        .background(Color(hex: "#00070C").opacity(0.6))
        .padding(.horizontal, 20)
    }
    .background(Color.black)
}
