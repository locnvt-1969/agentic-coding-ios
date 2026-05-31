// CommunityStandardsSectionView.swift
// MockProjectAIDD
//
// Private reusable row for one ContentSection inside CommunityStandardsView.
// Renders a yellow section title + body paragraphs in white.
// Design: https://momorph.ai/files/9ypp4enmFmdK3YAFJLIu6C/screens/xms7csmDhD

import SwiftUI

struct CommunityStandardsSectionView: View {
    let section: ContentSection

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title — Montserrat Bold 18 / yellow #FFEA9E
            Text(section.title)
                .font(.custom("Montserrat", size: 18).weight(.bold))
                .foregroundStyle(Color(hex: "FFEA9E"))
                .lineSpacing(6) // lineHeight 24 - fontSize 18 = 6 / 2 = 3 top+bottom

            // Body paragraphs
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(section.body.enumerated()), id: \.offset) { _, paragraph in
                    Text(paragraph)
                        .font(.custom("Montserrat", size: 14))
                        .foregroundStyle(.white)
                        .lineSpacing(6) // lineHeight 20 - fontSize 14 = 6
                        .tracking(0.25)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }
}

// MARK: - Figma sample data (sourced from design, used in Preview only)

extension CommunityStandard {
    // swiftlint:disable line_length
    static let figmaSample = CommunityStandard(sections: [
        ContentSection(
            id: "community",
            title: "Tiêu chuẩn cộng đồng",
            body: [
                "Tiêu chuẩn Cộng đồng (Community Standards) được xây dựng nhằm đảm bảo một môi trường văn minh, an toàn và tích cực cho tất cả thành viên tham gia phong trào ghi nhận, cảm ơn Sun* Kudos.",
                #"""
Các nội dung phát hiện có một trong những tiêu chí vi phạm bên dưới sẽ được gắn nhãn Spam và được hệ thống chủ động ẩn.

Sử dụng từ ngữ thô tục, chửi bậy, hay có nội dung xúc phạm, bôi nhọ.
Đề cập đến các vấn đề chính trị, tôn giáo, phân biệt giới tính.
Chứa số liệu cụ thể (doanh thu, hợp đồng, KPI, khách hàng, mã dự án, số tài khoản…).
Đề cập tên đối tác, khách hàng, tổ chức bên ngoài.
Chứa thông tin cá nhân (email, số điện thoại, địa chỉ, thông tin gia đình).
Gửi lặp lại 3+ tin nhắn có nội dung tương tự nhau trong thời gian ngắn.
Nội dung Kudos quá ngắn (dưới 30 kí tự), không có ngữ cảnh ("Cảm ơn nhiều", "Thanks nhé", "Good job!").
Gửi cho quá nhiều người/nhóm người trong thời gian ngắn (<3s/lời nhắn).
Ngôn từ spam (chỉ chứa ký tự như ".", ",", "...", hay ký tự không có nội dung).
Mức độ "tim" tăng đột biến bất thường (theo hành vi người dùng trung bình).
"""#
            ]
        ),
        ContentSection(
            id: "security",
            title: "Tiêu chuẩn bảo mật",
            body: [
                "Sunner cam kết bảo vệ thông tin. Mọi thành viên có trách nhiệm bảo mật nội dung chia sẻ trên hệ thống.\nBảo mật Thông tin: Toàn bộ thông tin Sunner chia sẻ sẽ được bảo mật trên hệ thống.\nPhạm vi Chia sẻ: Toàn bộ thông tin nhân sự và dự án trong hệ thống được bảo mật. Sunner vui lòng chỉ chia sẻ trong nội bộ Sun*.",
                "Liên hệ Hỗ trợ: Mọi thắc mắc, Sunner vui lòng liên hệ đại diện BTC SAA: Slack duong.thi.thuy.an để được hỗ trợ."
            ]
        )
    ])
    // swiftlint:enable line_length
}

#Preview {
    ZStack {
        Color(hex: "00101A").ignoresSafeArea()
        ScrollView {
            CommunityStandardsSectionView(section: CommunityStandard.figmaSample.sections[0])
                .padding(.horizontal, 20)
        }
    }
}
