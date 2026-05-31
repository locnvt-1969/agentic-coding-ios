// SunKudosSection.swift
// MockProjectAIDD
//
// Bottom "Sun* Kudos" section — displayed after AwardCriteriaSection.
// MoMorph node: mms_2.4_kudos (6885:10315)
// Screen: [iOS] Award_Top talent (fileKey: 9ypp4enmFmdK3YAFJLIu6C, screenId: c-QM3_zjkG)
//
// Design layout (width=335, height=490, gap=24):
//   header   — eyebrow "Phong trào ghi nhận" + divider + "Sun* Kudos" title
//   banner   — kudos banner image (335×145, borderRadius≈5, bg=#0F0F0F)
//   note     — ĐIỂM MỚI body paragraph (font 14/300, color=white, letterSpacing=0.25)
//   button   — "Chi tiết" CTA (160×40, bg=#FFEA9E, radius=4)
// Purely presentational — exposes onDetail callback.

import SwiftUI

struct SunKudosSection: View {
    var onDetail: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            sectionHeader
            kudosBanner
            noteText
            detailButton
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Section header
    // Design: gap=4, height=53
    //   eyebrow: 12px Montserrat Regular, color=white (#FFFF)
    //   divider: 1px, color=#2E3940
    //   title:   22px Montserrat Medium, color=#FFEA9E ("Sun* Kudos")
    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Phong trào ghi nhận")
                .font(.custom("Montserrat", size: 12).weight(.regular))
                .foregroundStyle(Color.white)

            Rectangle()
                .fill(Color(hex: "2E3940"))
                .frame(height: 1)

            Text("Sun* Kudos")
                .font(.custom("Montserrat", size: 22).weight(.medium))
                .foregroundStyle(Color.awardGold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Kudos banner image
    // Design: node mm_media_Sunkudos (6885:10317), 335×145, borderRadius=4.653
    // Background behind the image: #0F0F0F (from MM_MEDIA_Kudos Background fill)
    // Logo overlay: MM_MEDIA_Logo/Kudos (6885:10321), 118×21, at (195, 63) within 335×145 banner.
    // Position is proportional: ~58% from left, ~44% from top.
    private var kudosBanner: some View {
        Image("kudos-banner")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity)
            .frame(height: 145)
            .background(Color(hex: "0F0F0F"))
            .clipShape(RoundedRectangle(cornerRadius: 5))
            .overlay(alignment: .topLeading) {
                // Logo sits at (195, 63) within the 335×145 banner frame
                GeometryReader { geo in
                    let scaleX = geo.size.width / 335
                    Image("kudos-banner-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 118 * scaleX)
                        .offset(
                            x: 195 * scaleX,
                            y: 63 * (geo.size.height / 145)
                        )
                }
            }
    }

    // MARK: - Note / body text
    // Design: node txt (6885:10330)
    //   font: 14px Montserrat Light (300), color=white, lineHeight=20, letterSpacing=0.25
    //   First line "ĐIỂM MỚI CỦA SAA 2025" is visually bolder — apply semibold weight.
    private var noteText: some View {
        Group {
            Text("ĐIỂM MỚI CỦA SAA 2025\n")
                .font(.custom("Montserrat", size: 14).weight(.semibold))
                .foregroundStyle(Color.white)
            +
            Text("Hoạt động ghi nhận và cảm ơn đồng nghiệp - lần đầu tiên được diễn ra dành cho tất cả Sunner. Hoạt động sẽ được triển khai vào tháng 11/2025, khuyến khích người Sun* chia sẻ những lời ghi nhận, cảm ơn đồng nghiệp trên hệ thống do BTC công bố. Đây sẽ là chất liệu để Hội đồng Heads tham khảo trong quá trình lựa chọn người đạt giải.")
                .font(.custom("Montserrat", size: 14).weight(.light))
                .foregroundStyle(Color.white)
        }
        .lineSpacing(6) // ~20px lineHeight at 14px font
        .tracking(0.25)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - "Chi tiết" button
    // Design: Button node 6885:10331
    //   width=160, height=40, bg=#FFEA9E, borderRadius=4, padding=12
    //   Label: "Chi tiết" + arrow icon (I6885:10331;28:1997), 14px Montserrat Medium, color=#00101A
    private var detailButton: some View {
        Button(action: { onDetail?() }) {
            HStack(spacing: 4) {
                Text("Chi tiết")
                    .font(.custom("Montserrat", size: 14).weight(.medium))
                    .foregroundStyle(Color.awardDark)

                Image("ic-button-arrow")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .foregroundStyle(Color.awardDark)
            }
            .frame(width: 160, height: 40)
            .background(Color.awardGold)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "00101A").ignoresSafeArea()
        ScrollView {
            SunKudosSection(onDetail: {})
                .padding(.horizontal, 20)
                .padding(.vertical, 24)
        }
    }
}
