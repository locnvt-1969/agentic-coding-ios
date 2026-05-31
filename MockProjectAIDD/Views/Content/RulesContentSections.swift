// RulesContentSections.swift
// MockProjectAIDD
//
// Section subviews for RulesView: header, badge tiers, icon collection,
// kudos national, and action buttons. All purely presentational.

import SwiftUI

// MARK: - Section 4.1 Header

struct RulesHeaderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Thể lệ")
                .font(.custom("Montserrat", size: 18).weight(.bold))
                .foregroundStyle(Color(hex: "FFEA9E"))

            VStack(alignment: .leading, spacing: 16) {
                Text("NGƯỜI NHẬN KUDOS: HUY HIỆU HERO CHO NHỮNG ẢNH HƯỞNG TÍCH CỰC")
                    .font(.custom("Montserrat", size: 14).weight(.bold))
                    .foregroundStyle(Color(hex: "FFEA9E"))
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)

                Text("Dựa trên số lượng đồng đội gửi trao Kudos, bạn sẽ sở hữu Huy hiệu Hero tương ứng, được hiển thị trực tiếp cạnh tên profile")
                    .font(.custom("Montserrat", size: 14).weight(.regular))
                    .foregroundStyle(.white)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

// MARK: - Section 4.2 Badge Tiers

struct RulesBadgeTiersSection: View {
    private struct Tier {
        let imageName: String?
        let label: String
        let criteria: String
        let description: String
    }

    private let tiers: [Tier] = [
        Tier(
            imageName: "rules_badge_new_hero",
            label: "New Hero",
            criteria: "Có 1-4 người gửi Kudos cho bạn",
            description: "Hành trình lan tỏa điều tốt đẹp bắt đầu – những lời cảm ơn và ghi nhận đầu tiên đã tìm đến bạn."
        ),
        Tier(
            imageName: nil,
            label: "Rising Hero",
            criteria: "Có 5-9 người gửi Kudos cho bạn",
            description: "Hành trình lan tỏa điều tốt đẹp bắt đầu – những lời cảm ơn và ghi nhận đầu tiên đã tìm đến bạn."
        ),
        Tier(
            imageName: nil,
            label: "Super Hero",
            criteria: "Có 10–20 người gửi Kudos cho bạn",
            description: "Bạn đã trở thành biểu tượng được tin tưởng và yêu quý,\nngười luôn sẵn sàng hỗ trợ và được nhiều đồng đội nhớ đến."
        ),
        Tier(
            imageName: nil,
            label: "Legend Hero",
            criteria: "Có hơn 20 người gửi Kudos cho bạn",
            description: "Bạn đã trở thành biểu tượng được tin tưởng và yêu quý,\nngười luôn sẵn sàng hỗ trợ và được nhiều đồng đội nhớ đến."
        )
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(tiers.indices, id: \.self) { i in
                RulesBadgeRow(
                    badgeImageName: tiers[i].imageName,
                    badgeLabel: tiers[i].label,
                    criteria: tiers[i].criteria,
                    description: tiers[i].description
                )
            }
        }
    }
}

// MARK: - Section 4.3 Icon Collection

struct RulesIconCollectionSection: View {
    // Icons sourced from the shared SunValueIcon model (also drives the Profile collection).
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("NGƯỜI GỬI KUDOS: SƯU TẬP TRỌN BỘ 6 ICON, NHẬN NGAY PHẦN QUÀ BÍ ẨN")
                .font(.custom("Montserrat", size: 14).weight(.regular))
                .foregroundStyle(Color(hex: "FFEA9E"))
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            Text("Mỗi lời Kudos bạn gửi sẽ được đăng tải trên hệ thống và nhận về những lượt ❤️ từ cộng đồng Sunner. Cứ mỗi 5 lượt ❤️, bạn sẽ được mở 1 Secret Box, với cơ hội nhận về một trong 6 icon độc quyền của SAA.")
                .font(.custom("Montserrat", size: 14).weight(.regular))
                .foregroundStyle(.white)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)

            // LazyVGrid: 2 rows × 3 columns — prevents overflow on narrow devices (SE).
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3),
                spacing: 12
            ) {
                ForEach(SunValueIcon.allCases) { icon in
                    RulesIconBadgeItem(imageName: icon.imageName, label: icon.label)
                }
            }

            Text("Những Sunner thu thập trọn bộ 6 icon sẽ nhận về một phần quà bí ẩn từ SAA 2025.")
                .font(.custom("Montserrat", size: 14).weight(.regular))
                .foregroundStyle(.white)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Section 4.4 Kudos National

struct RulesKudosNationalSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("KUDOS QUỐC DÂN")
                .font(.custom("Montserrat", size: 14).weight(.bold))
                .foregroundStyle(Color(hex: "FFEA9E"))

            Text("5 Kudos nhận về nhiều ❤️ nhất toàn Sun* sẽ chính thức trở thành Kudos Quốc Dân và được trao phần quà đặc biệt từ SAA 2025: Root Further.")
                .font(.custom("Montserrat", size: 14).weight(.regular))
                .foregroundStyle(.white)
                .lineSpacing(6)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Section 4.5 Action Buttons

struct RulesActionButtons: View {
    var onClose: (() -> Void)?
    var onWriteKudos: (() -> Void)?

    var body: some View {
        HStack(spacing: 12) {
            Button(action: { onClose?() }) {
                Text("Đóng")
                    .font(.custom("Montserrat", size: 14).weight(.medium))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .background(Color(hex: "FFEA9E").opacity(0.10))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(hex: "998C5F"), lineWidth: 0.5)
            )

            Button(action: { onWriteKudos?() }) {
                Text("Viết Kudos")
                    .font(.custom("Montserrat", size: 14).weight(.medium))
                    .foregroundStyle(Color(hex: "00101A"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .background(Color(hex: "FFEA9E"))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}
