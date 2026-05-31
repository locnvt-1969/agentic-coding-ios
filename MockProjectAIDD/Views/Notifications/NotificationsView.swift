// NotificationsView.swift
// MockProjectAIDD
//
// Notifications screen — presentational only.
// Design: Figma [iOS] Notifications (fileKey: 9ypp4enmFmdK3YAFJLIu6C, screenId: _b68CBWKl5)
//
// Public contract:
//   NotificationsView(items:isLoading:onTap:onMarkAllRead:onBack:)
//
// Layout: keyvisual BG → NotificationsTopNav → scrollable body
//   body: "mark all read" row (unread-only) → notification list card | loading | empty

import SwiftUI

struct NotificationsView: View {
    let items: [AppNotification]
    var isLoading: Bool = false
    let onTap: (AppNotification) -> Void
    let onMarkAllRead: () -> Void
    var onBack: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            keyvisualBackground
            VStack(spacing: 0) {
                NotificationsTopNav(onBack: onBack)
                scrollBody
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarHidden(true)
    }

    // MARK: - Keyvisual background

    private var keyvisualBackground: some View {
        Image("notification_keyvisual_bg")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    // MARK: - Scrollable body

    private var scrollBody: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                if !isLoading && items.contains(where: { !$0.isRead }) {
                    markAllReadRow
                }
                bodyContent
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    // MARK: - "Mark all read" button

    private var markAllReadRow: some View {
        Button(action: onMarkAllRead) {
            HStack(spacing: 4) {
                Image(systemName: "line.3.horizontal")
                    .font(.system(size: 14))
                    .frame(width: 24, height: 24)
                Text("Đánh dấu đọc tất cả")
                    .font(.custom("Montserrat", size: 14).weight(.bold))
                    .tracking(0.25)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 40)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Body content switcher

    @ViewBuilder
    private var bodyContent: some View {
        if isLoading {
            loadingState
        } else if items.isEmpty {
            emptyState
        } else {
            notificationList
        }
    }

    // MARK: - Notification list card

    private var notificationList: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                NotificationRow(
                    item: item,
                    onTap: onTap,
                    showsDivider: index < items.count - 1
                )
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color(hex: "#00070C").opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    // MARK: - Loading state

    private var loadingState: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
            Text("Đang tải...")
                .font(.custom("Montserrat", size: 14))
                .foregroundStyle(Color(hex: "#999999"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48, weight: .light))
                .foregroundStyle(Color(hex: "#999999"))
            Text("Không có thông báo nào")
                .font(.custom("Montserrat", size: 16).weight(.medium))
                .foregroundStyle(.white)
            Text("Bạn chưa có thông báo mới.")
                .font(.custom("Montserrat", size: 14))
                .foregroundStyle(Color(hex: "#999999"))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 80)
    }
}

// MARK: - Previews

#Preview("Populated (mix read/unread)") {
    NotificationsView(
        items: NotificationsPreviewData.figmaSamples,
        isLoading: false,
        onTap: { _ in },
        onMarkAllRead: {},
        onBack: {}
    )
    .background(Color.black)
}

#Preview("Loading") {
    NotificationsView(items: [], isLoading: true, onTap: { _ in }, onMarkAllRead: {}, onBack: {})
        .background(Color.black)
}

#Preview("Empty") {
    NotificationsView(items: [], isLoading: false, onTap: { _ in }, onMarkAllRead: {}, onBack: {})
        .background(Color.black)
}
