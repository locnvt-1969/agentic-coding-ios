// NotificationsView.swift
// MockProjectAIDD
//
// Notifications screen — presentational only.
// Design: Figma [iOS] Notifications (fileKey: 9ypp4enmFmdK3YAFJLIu6C, screenId: _b68CBWKl5)
//
// Layout mirrors CommunityStandardsView (commit 61ada84): a plain ScrollView whose content
// respects the top safe area, the nav bar pinned via `.safeAreaInset(edge: .top)`, and the
// keyvisual drawn via `.background`. Avoids the `.ignoresSafeArea(.top)` + scroll anti-pattern.

import SwiftUI

struct NotificationsView: View {
    let items: [AppNotification]
    var isLoading: Bool = false
    let onTap: (AppNotification) -> Void
    let onMarkAllRead: () -> Void
    var onCommunityStandards: (() -> Void)? = nil
    var onBack: (() -> Void)? = nil

    var body: some View {
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
        .background(alignment: .top) {
            keyvisualBackground
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            NotificationsTopNav(onBack: onBack)
        }
        .toolbar(.hidden, for: .navigationBar)
    }

    // MARK: - Keyvisual background

    private var keyvisualBackground: some View {
        ZStack {
            Color(hex: "#00101A")
            Image("notification_keyvisual_bg")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .clipped()
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#00101A").opacity(0), location: 0),
                    .init(color: Color(hex: "#00101A"),            location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
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
                    onCommunityStandards: onCommunityStandards,
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
    NavigationStack {
        NotificationsView(
            items: NotificationsPreviewData.figmaSamples,
            isLoading: false,
            onTap: { _ in },
            onMarkAllRead: {},
            onCommunityStandards: {},
            onBack: {}
        )
    }
}

#Preview("Loading") {
    NavigationStack {
        NotificationsView(items: [], isLoading: true, onTap: { _ in }, onMarkAllRead: {}, onBack: {})
    }
}

#Preview("Empty") {
    NavigationStack {
        NotificationsView(items: [], isLoading: false, onTap: { _ in }, onMarkAllRead: {}, onBack: {})
    }
}
