// AwardTopNavigationBar.swift
// MockProjectAIDD
//
// Top chrome navigation bar matching MoMorph design node mms_1_header.
// Screen: [iOS] Award_Top talent (fileKey: 9ypp4enmFmdK3YAFJLIu6C, screenId: c-QM3_zjkG)
//
// Layout (design coords, h=104, content starts y=52):
//   Left  — SAA logo (48×44), leading padding 20
//   Right — language pill (VN flag + "VN" + chevron-down) + search + bell, trailing padding 20
// Purely presentational — exposes callbacks only.

import SwiftUI

struct AwardTopNavigationBar: View {
    // MARK: - Callbacks
    var onLanguage: (() -> Void)? = nil
    var onSearch: (() -> Void)? = nil
    var onNotifications: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            logoView
            Spacer()
            actionsRow
        }
        .padding(.horizontal, 20)
        .frame(height: 44)
    }

    // MARK: - Logo
    // Reuse the logo-homepage asset from Login catalog — same asset confirmed by media node name.
    private var logoView: some View {
        Image("logo-homepage")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 48, height: 44)
    }

    // MARK: - Right actions row (language + search + bell)
    // Design: gap=10, total width=122, height=32
    private var actionsRow: some View {
        HStack(spacing: 10) {
            languageButton
            searchButton
            notificationButton
        }
    }

    // Language pill: VN flag (drawn) + "VN" text + chevron-down
    // Design: width=90, height=32, padding 4px 0 4px 8px, gap=8, borderRadius=4
    private var languageButton: some View {
        Button(action: { onLanguage?() }) {
            HStack(spacing: 8) {
                // VN flag — country frame: width=50, VN flag icon=24×24 + "VN" text
                HStack(spacing: 4) {
                    VNFlagIcon()
                        .frame(width: 20, height: 15)
                    Text("VN")
                        .font(.custom("Montserrat", size: 14).weight(.medium))
                        .foregroundStyle(.white)
                }
                Image(systemName: "chevron.down")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(.vertical, 4)
            .padding(.leading, 8)
        }
    }

    // Search icon: mm_media_search (24×24 SVG, fill=#00101A in design but displayed on dark bg → white)
    private var searchButton: some View {
        Button(action: { onSearch?() }) {
            Image("top-nav-search-icon")
                .renderingMode(.template)
                .resizable()
                .frame(width: 24, height: 24)
                .foregroundStyle(.white)
        }
    }

    // Notification bell with red dot badge
    // Design: bell=24×24, badge dot=8×8 red (#D4271D) at top-right
    private var notificationButton: some View {
        Button(action: { onNotifications?() }) {
            ZStack(alignment: .topTrailing) {
                Image("top-nav-notification-icon")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 24, height: 24)
                    .foregroundStyle(.white)
                Circle()
                    .fill(Color(hex: "D4271D"))
                    .frame(width: 8, height: 8)
                    .offset(x: 1, y: -1)
            }
        }
    }
}

// MARK: - VN Flag drawn in SwiftUI
// Vietnam flag: red background + yellow 5-pointed star
// Used when MM_MEDIA_IC VN Flag has no pre-uploaded asset (null in media_files)
private struct VNFlagIcon: View {
    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            ZStack {
                Rectangle()
                    .fill(Color(hex: "DA251D"))
                // 5-pointed yellow star centered
                StarShape(points: 5, innerRatio: 0.38)
                    .fill(Color(hex: "FFFF00"))
                    .frame(width: w * 0.5, height: h * 0.5)
                    .position(x: w / 2, y: h / 2)
            }
        }
    }
}

// MARK: - Star shape helper
private struct StarShape: Shape {
    let points: Int
    let innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerR = min(rect.width, rect.height) / 2
        let innerR = outerR * innerRatio
        let angleOffset = -CGFloat.pi / 2
        var path = Path()
        for i in 0 ..< points * 2 {
            let angle = angleOffset + CGFloat(i) * .pi / CGFloat(points)
            let r = i.isMultiple(of: 2) ? outerR : innerR
            let pt = CGPoint(x: center.x + r * cos(angle),
                             y: center.y + r * sin(angle))
            if i == 0 { path.move(to: pt) } else { path.addLine(to: pt) }
        }
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        Color(hex: "00101A").ignoresSafeArea()
        AwardTopNavigationBar(
            onLanguage: {},
            onSearch: {},
            onNotifications: {}
        )
    }
    .frame(height: 60)
}
