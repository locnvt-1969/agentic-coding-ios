// RulesView.swift
// MockProjectAIDD
//
// [iOS] Thể lệ — read-only, scrollable rules screen.
// Contract: RulesView(rule: Rule, onClose: () -> Void, onWriteKudos: () -> Void)
// Purely presentational — no service calls, no ViewModel ownership.
//
// Rules body is a fixed Figma-designed layout; `rule.title` drives the header.
// `rule.sections` is intentionally not iterated (bespoke design, not generic content).
// Phase-19 passes a Rule whose title is used; sections may be empty.

import SwiftUI

struct RulesView: View {
    let rule: Rule
    var onClose: (() -> Void)? = nil
    var onWriteKudos: (() -> Void)? = nil

    // Layout mirrors CommunityStandardsView (commit 61ada84): a plain ScrollView whose
    // content respects the top safe area, the custom nav bar pinned via `.safeAreaInset`,
    // and the keyvisual drawn via `.background`. Avoids the `.ignoresSafeArea(.top)` + scroll
    // anti-pattern that clips content inside a NavigationStack.
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            RulesContentCard(rule: rule, onClose: onClose, onWriteKudos: onWriteKudos)
        }
        .background(alignment: .top) {
            RulesBackgroundLayer()
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            RulesNavBar(title: rule.title, onBack: onClose)
        }
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Background

// Fills the full device width and fades to the base background color.
private struct RulesBackgroundLayer: View {
    var body: some View {
        ZStack {
            Color(hex: "00101A")
            Image("MM_MEDIA_Keyvisual_BG")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .clipped()
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "001320").opacity(0), location: 0),
                    .init(color: Color(hex: "00101A"),            location: 0.5)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .frame(maxWidth: .infinity)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }
}

// MARK: - Navigation Bar

// Stretches to full device width. Title is centered via ZStack (mirrors
// CommunityStandardsNavBar pattern) so it won't truncate on any standard device.
private struct RulesNavBar: View {
    let title: String
    var onBack: (() -> Void)?

    var body: some View {
        ZStack {
            // Centered title — expands to full width, truncates with ellipsis on
            // extreme cases rather than clipping.
            Text(title)
                .font(.custom("Helvetica Neue", size: 17).weight(.medium))
                .foregroundStyle(.white)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            // Leading back button overlaid on the same row.
            HStack {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 18, height: 24)
                }
                .padding(.leading, 7)
                Spacer()
            }
        }
        .frame(height: 42)
        .padding(.horizontal, 9)
        .frame(maxWidth: .infinity)
        // Dark → transparent gradient; extends up behind the status bar for legibility.
        .background(
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "00101A"),              location: 0),
                    .init(color: Color(hex: "00101A").opacity(0.3), location: 0.764),
                    .init(color: Color(hex: "00101A").opacity(0.1), location: 0.928),
                    .init(color: .clear,                            location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
}

// MARK: - Content Card

// Rules body is a fixed Figma-designed layout; `rule.title` drives the header.
// `rule.sections` is intentionally not iterated (bespoke design, not generic content).
// Phase-19 passes a Rule whose title is used; sections may be empty.
struct RulesContentCard: View {
    let rule: Rule
    var onClose: (() -> Void)?
    var onWriteKudos: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            RulesHeaderSection()
            Rectangle().fill(Color(hex: "2E3940")).frame(height: 1)
            RulesBadgeTiersSection()
            RulesIconCollectionSection()
            RulesKudosNationalSection()
            RulesActionButtons(onClose: onClose, onWriteKudos: onWriteKudos)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "00101A"))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - Preview

#Preview {
    RulesView(
        rule: Rule(
            title: "Thể lệ",
            sections: [
                ContentSection(
                    id: "s1",
                    title: "NGƯỜI NHẬN KUDOS",
                    body: ["Dựa trên số lượng đồng đội gửi trao Kudos, bạn sẽ sở hữu Huy hiệu Hero tương ứng."]
                ),
                ContentSection(
                    id: "s2",
                    title: "NGƯỜI GỬI KUDOS",
                    body: ["Mỗi lời Kudos bạn gửi sẽ được đăng tải trên hệ thống."]
                ),
                ContentSection(
                    id: "s3",
                    title: "KUDOS QUỐC DÂN",
                    body: ["5 Kudos nhận về nhiều ❤️ nhất toàn Sun* sẽ chính thức trở thành Kudos Quốc Dân."]
                )
            ]
        ),
        onClose: {},
        onWriteKudos: {}
    )
}
