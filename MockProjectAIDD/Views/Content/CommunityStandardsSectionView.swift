// CommunityStandardsSectionView.swift
// MockProjectAIDD
//
// Private reusable row for one ContentSection inside CommunityStandardsView.
// Renders: gold title → bold lead → regular paragraphs → numbered list →
// bullet list → gold-bold highlight. All blocks are optional.
// Design: https://momorph.ai/files/9ypp4enmFmdK3YAFJLIu6C/screens/xms7csmDhD

import SwiftUI

struct CommunityStandardsSectionView: View {
    let section: ContentSection

    private let bodyFont = Font.custom("Montserrat", size: 14)
    private let bodyGold = Color(hex: "FFEA9E")

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Section title — Montserrat Bold 18 / gold
            Text(section.title)
                .font(.custom("Montserrat", size: 18).weight(.bold))
                .foregroundStyle(bodyGold)
                .lineSpacing(6)

            // Bold-white lead paragraph
            if let lead = section.leadParagraph {
                paragraph(lead, weight: .bold)
            }

            // Regular body paragraphs
            ForEach(Array(section.body.enumerated()), id: \.offset) { _, text in
                paragraph(text, weight: .regular)
            }

            // Numbered list (1. … with hanging indent)
            if !section.numberedItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(section.numberedItems.enumerated()), id: \.offset) { index, item in
                        listRow(marker: "\(index + 1).", markerWidth: 24, text: item)
                    }
                }
            }

            // Bullet list
            if !section.bulletItems.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(Array(section.bulletItems.enumerated()), id: \.offset) { _, item in
                        listRow(marker: "•", markerWidth: 14, text: item)
                    }
                }
            }

            // Gold-bold highlight (e.g. contact note)
            if let highlight = section.highlight {
                Text(highlight)
                    .font(bodyFont.weight(.bold))
                    .foregroundStyle(bodyGold)
                    .lineSpacing(6)
                    .tracking(0.25)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 12)
    }

    // MARK: Helpers

    private func paragraph(_ text: String, weight: Font.Weight) -> some View {
        Text(text)
            .font(bodyFont.weight(weight))
            .foregroundStyle(.white)
            .lineSpacing(6)
            .tracking(0.25)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func listRow(marker: String, markerWidth: CGFloat, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(marker)
                .font(bodyFont)
                .foregroundStyle(.white)
                .frame(width: markerWidth, alignment: .trailing)
            Text(text)
                .font(bodyFont)
                .foregroundStyle(.white)
                .lineSpacing(6)
                .tracking(0.25)
                .frame(maxWidth: .infinity, alignment: .leading)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Figma content (canonical source — sourced from design)

extension CommunityStandard {
    // swiftlint:disable line_length
    static let figmaSample = CommunityStandard(sections: [
        ContentSection(
            id: "community",
            title: "Tiêu chuẩn cộng đồng",
            body: [
                "Các nội dung phát hiện có một trong những tiêu chí vi phạm bên dưới sẽ được gắn nhãn Spam và được hệ thống chủ động ẩn."
            ],
            leadParagraph: "Tiêu chuẩn Cộng đồng (Community Standards) được xây dựng nhằm đảm bảo một môi trường văn minh, an toàn và tích cực cho tất cả thành viên tham gia phong trào ghi nhận, cảm ơn Sun* Kudos.",
            numberedItems: [
                "Sử dụng từ ngữ thô tục, chửi bậy, hay có nội dung xúc phạm, bôi nhọ.",
                "Đề cập đến các vấn đề chính trị, tôn giáo, phân biệt giới tính.",
                "Chứa số liệu cụ thể (doanh thu, hợp đồng, KPI, khách hàng, mã dự án, số tài khoản…).",
                "Đề cập tên đối tác, khách hàng, tổ chức bên ngoài.",
                "Chứa thông tin cá nhân (email, số điện thoại, địa chỉ, thông tin gia đình).",
                "Gửi lặp lại 3+ tin nhắn có nội dung tương tự nhau trong thời gian ngắn.",
                "Nội dung Kudos quá ngắn (dưới 30 kí tự), không có ngữ cảnh (\u{201C}Cảm ơn nhiều\u{201D}, \u{201C}Thanks nhé\u{201D}, \u{201C}Good job!\u{201D}).",
                "Gửi cho quá nhiều người/nhóm người trong thời gian ngắn (<3s/lời nhắn).",
                "Ngôn từ spam (chỉ chứa ký tự như \u{201C}.\u{201D}, \u{201C},\u{201D}, \u{201C}...\u{201D}, hay ký tự không có nội dung).",
                "Mức độ \u{201C}tim\u{201D} tăng đột biến bất thường (theo hành vi người dùng trung bình)."
            ]
        ),
        ContentSection(
            id: "security",
            title: "Tiêu chuẩn bảo mật",
            leadParagraph: "Sunner cam kết bảo vệ thông tin. Mọi thành viên có trách nhiệm bảo mật nội dung chia sẻ trên hệ thống.",
            bulletItems: [
                "Bảo mật Thông tin: Toàn bộ thông tin Sunner chia sẻ sẽ được bảo mật trên hệ thống.",
                "Phạm vi Chia sẻ: Toàn bộ thông tin nhân sự và dự án trong hệ thống được bảo mật. Sunner vui lòng chỉ chia sẻ trong nội bộ Sun*."
            ],
            highlight: "Liên hệ Hỗ trợ: Mọi thắc mắc, Sunner vui lòng liên hệ đại diện BTC SAA: Slack duong.thi.thuy.an để được hỗ trợ."
        )
    ])
    // swiftlint:enable line_length
}

#Preview {
    ScrollView {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(CommunityStandard.figmaSample.sections) { section in
                CommunityStandardsSectionView(section: section)
            }
        }
        .padding(.horizontal, 20)
    }
    .background(Color(hex: "00101A"))
}
