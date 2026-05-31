// HomeViewMockData.swift
// MockProjectAIDD
//
// Mock data sourced directly from Figma design content.
// Used only in #Preview blocks and HomeViewModel initial state.
// Track B replaces these with API responses.

import Foundation

enum HomeViewMockData {

    static let awards: [AwardItem] = [
        AwardItem(
            id: "top-talent",
            thumbnailName: "home-award-card-bg",
            name: "Top Talent",
            description: "Giải thưởng Top Talent vinh danh những cá nhân xuất sắc..."
        ),
        AwardItem(
            id: "top-project",
            thumbnailName: "home-award-card-bg",
            name: "Top Project",
            description: "Giải thưởng Top Project vinh danh các tập thể dự án xuất..."
        ),
        AwardItem(
            id: "top-manager",
            thumbnailName: "home-award-card-bg",
            name: "Top Manager",
            description: "Giải thưởng Top Manager vinh danh những nhà quản lý xuất..."
        ),
    ]

    static let themeDescription = """
Không đơn thuần là một cái tên, "Root Further" chính là tinh thần mà mỗi người Sun* đang hướng tới: luôn nhìn nhận sâu sắc trong mọi bối cảnh và không ngừng sáng tạo, mở rộng bản thân để vượt qua những giới hạn mà chính mình đã từng đặt ra. Mượn hình ảnh ẩn dụ của lý thuyết phối màu, chỉ từ ba màu cơ bản: đỏ, vàng và lam, sức sáng tạo vô tận của mỗi cá nhân có thể tạo ra số lượng màu sắc gần như vô hạn, với mỗi gam màu đều đại diện cho sự bứt phá và sáng tạo không giới hạn.
"""

    static let kudosDescription = """
Hoạt động ghi nhận và cảm ơn đồng nghiệp - lần đầu tiên được diễn ra dành cho tất cả Sunner. Hoạt động sẽ được triển khai vào tháng 11/2025, khuyến khích người Sun* chia sẻ những lời ghi nhận, cảm ơn đồng nghiệp trên hệ thống do BTC công bố. Đây sẽ là chất liệu để Hội đồng Heads tham khảo trong quá trình lựa chọn người đạt giải.
"""
}
