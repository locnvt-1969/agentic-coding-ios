// NotificationRow.swift
// MockProjectAIDD
//
// Single notification row — presentational only.
// Design: Figma [iOS] Notifications / mms_B.1_Noti (unread) + Noti (read)
// Layout: 8pt padding, icon 24×24 pinned top, content block, optional unread dot.
// Unread (mms_B.1_Noti): message weight 700, red dot 8×8 at trailing top.
// Read   (Noti):          message weight 400, no dot.
// Divider: 1pt #2E3940 at bottom.

import SwiftUI

struct NotificationRow: View {
    let item: AppNotification
    let onTap: (AppNotification) -> Void
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

    // MARK: - Content: message + timestamp

    private var contentBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.message)
                .font(.custom("Montserrat", size: 14)
                    .weight(item.isRead ? .regular : .bold))
                .foregroundStyle(.white)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

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

// MARK: - Kind helpers

private extension AppNotification.Kind {
    var systemImageName: String {
        switch self {
        case .kudoReceived:  return "envelope"
        case .kudoReaction:  return "heart"
        case .awardGranted:  return "star"
        case .system:        return "exclamationmark.triangle"
        }
    }

    var iconColor: Color {
        switch self {
        case .kudoReceived:  return Color(hex: "#4A9EE0")  // blue envelope
        case .kudoReaction:  return Color(hex: "#E05E7A")  // pink heart
        case .awardGranted:  return Color(hex: "#E8C84A")  // gold star
        case .system:        return Color(hex: "#E8A44A")  // amber warning
        }
    }
}

// MARK: - Preview

#Preview("NotificationRow") {
    VStack(spacing: 0) {
        NotificationRow(
            item: AppNotification(
                id: "n1",
                kind: .kudoReceived,
                actor: .sample,
                message: "Sunner Huỳnh Dương Xuân Nhật vừa gửi đến bạn lời ghi nhận đầy yêu thương!",
                createdAt: Date(timeIntervalSinceNow: -900),
                isRead: false
            ),
            onTap: { _ in }
        )
        NotificationRow(
            item: AppNotification(
                id: "n2",
                kind: .kudoReaction,
                actor: .sample,
                message: "Wow! Lời nhắn gửi của bạn cho Sunner <tên Sunner> vừa nhận thêm lượt tim!",
                createdAt: Date(timeIntervalSinceNow: -3600),
                isRead: true
            ),
            onTap: { _ in }
        )
        NotificationRow(
            item: AppNotification(
                id: "n3",
                kind: .awardGranted,
                actor: nil,
                message: "Chúc mừng! Bạn vừa nhận được lượt mở Secret Box mới! Click vào đây để mở ngay nhé!",
                createdAt: Date(timeIntervalSinceNow: -86400),
                isRead: true
            ),
            onTap: { _ in }
        )
        NotificationRow(
            item: AppNotification(
                id: "n4",
                kind: .system,
                actor: nil,
                message: "Tiếc quá! Bạn có một lời nhắn bị tạm ẩn vì \"vướng\" một số tiêu chuẩn! Hãy xem các tiêu chuẩn và gửi lại cho đồng đội nhé!\nTiêu chuẩn cộng đồng",
                createdAt: Date(timeIntervalSinceNow: -2_592_000),
                isRead: true
            ),
            onTap: { _ in },
            showsDivider: false
        )
    }
    .background(Color(hex: "#00070C").opacity(0.6))
    .padding(.horizontal, 20)
}
