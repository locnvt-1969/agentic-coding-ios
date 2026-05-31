// NotificationsPreviewData.swift
// MockProjectAIDD
//
// Figma sample notifications — used by SwiftUI previews AND by the
// FeatureFlags.useMockNotifications demo path (NotificationsViewModel.load()).
// Content mirrors the 7 notification types on the [iOS] Notifications screen.

import Foundation

enum NotificationsPreviewData {
    static let figmaSamples: [AppNotification] = [
        AppNotification(
            id: "notif-1", kind: .kudoReceived, actor: .sample,
            message: "Sunner Huỳnh Dương Xuân Nhật vừa gửi đến bạn lời ghi nhận đầy yêu thương!",
            createdAt: Date(timeIntervalSinceNow: -900), isRead: false
        ),
        AppNotification(
            id: "notif-2", kind: .kudoReaction, actor: .sample,
            message: "Wow! Lời nhắn gửi của bạn cho Sunner <tên Sunner> vừa nhận thêm lượt tim!",
            createdAt: Date(timeIntervalSinceNow: -3_600), isRead: false
        ),
        AppNotification(
            id: "notif-3", kind: .secretBox, actor: nil,
            message: "Chúc mừng! Bạn vừa nhận được lượt mở Secret Box mới! Click vào đây để mở ngay nhé!",
            createdAt: Date(timeIntervalSinceNow: -86_400), isRead: true
        ),
        AppNotification(
            id: "notif-4", kind: .levelUp, actor: nil,
            message: "Bạn nhận được <X> lời nhắn gửi từ đồng nghiệp và thăng hạng <tên level>!\nTiếp tục lan tỏa năng lượng tích cực đến đồng nghiệp nhé!",
            createdAt: Date(timeIntervalSinceNow: -86_400), isRead: true
        ),
        AppNotification(
            id: "notif-5", kind: .contentHidden, actor: nil,
            message: "Tiếc quá! Bạn có một lời nhắn bị tạm ẩn vì \"vướng\" một số tiêu chuẩn! Hãy xem các tiêu chuẩn và gửi lại cho đồng đội nhé!",
            createdAt: Date(timeIntervalSinceNow: -2_592_000), isRead: true
        ),
        AppNotification(
            id: "notif-6", kind: .badgeCollected, actor: nil,
            message: "Chúc mừng bạn đã thu thập đủ 6 huy hiệu của SAA. Bạn đã nhận được phần quà từ BTC chính là <X>. BTC sẽ liên hệ để gửi quà đến bạn vào cuối sự kiện.",
            createdAt: Date(timeIntervalSinceNow: -2_592_000), isRead: true
        ),
        AppNotification(
            id: "notif-7", kind: .reviewRequest, actor: nil,
            message: "\"Có <x> lời nhắn cần bạn xem xét!\" Một lời nhắn vừa bị hệ thống gắn cờ nghi ngờ vi phạm tiêu chuẩn. Vui lòng kiểm tra và xác nhận trạng thái: Hợp lệ / Tạm ẩn / Reject.",
            createdAt: Date(timeIntervalSinceNow: -2_592_000), isRead: true
        ),
    ]
}
