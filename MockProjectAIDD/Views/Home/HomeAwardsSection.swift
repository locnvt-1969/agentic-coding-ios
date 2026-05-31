// HomeAwardsSection.swift
// MockProjectAIDD
//
// mms_4 — Awards section
// Header: "Sun* Annual Awards 2025" subtitle + "Hệ thống giải thưởng" title (mms_4.1)
// Body: switches on AwardsLoadState to show loading / loaded cards / empty / error+retry

import SwiftUI

struct HomeAwardsSection: View {

    // MARK: - Props
    let state: AwardsLoadState
    let onAwardCardTap: (String) -> Void
    let onRetry: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section divider
            Rectangle()
                .fill(Color.white.opacity(0.08))
                .frame(height: 1)
                .padding(.bottom, 16)

            // mms_4.1 — section header
            // Figma: small label white 12pt weight 400; main title cream #FFEA9E 22pt weight 500.
            VStack(alignment: .leading, spacing: 4) {
                Text("Sun* Annual Awards 2025")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white)

                Text("Hệ thống giải thưởng")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color(hex: "#FFEA9E"))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 16)

            // mms_4.2 — state-driven content
            awardContent
                .frame(minHeight: 120)
        }
        .padding(.top, 20)
        .padding(.bottom, 24)
        .background(Color(hex: "#060E16"))
    }

    // MARK: - State switch

    @ViewBuilder
    private var awardContent: some View {
        switch state {
        case .idle:
            Color.clear

        case .loading:
            HStack {
                Spacer()
                ProgressView()
                    .tint(.white)
                Spacer()
            }

        case .loaded(let awards):
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(awards) { award in
                        HomeAwardCard(award: award) {
                            onAwardCardTap(award.id)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 4)
            }

        case .empty:
            HStack {
                Spacer()
                Text("Chưa có giải thưởng")
                    .font(.system(size: 14, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.55))
                Spacer()
            }

        case .error(let msg):
            VStack(spacing: 10) {
                Text(msg)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Button("Thử lại", action: onRetry)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .strokeBorder(Color.white.opacity(0.4), lineWidth: 1)
                    )
                    .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview("Loaded") {
    HomeAwardsSection(
        state: .loaded(HomeViewMockData.awards),
        onAwardCardTap: { _ in },
        onRetry: {}
    )
}

#Preview("Loading") {
    HomeAwardsSection(state: .loading, onAwardCardTap: { _ in }, onRetry: {})
        .background(Color(hex: "#060E16"))
}

#Preview("Error") {
    HomeAwardsSection(
        state: .error("Không tải được dữ liệu. Kiểm tra kết nối mạng."),
        onAwardCardTap: { _ in },
        onRetry: {}
    )
    .background(Color(hex: "#060E16"))
}

#Preview("Empty") {
    HomeAwardsSection(state: .empty, onAwardCardTap: { _ in }, onRetry: {})
        .background(Color(hex: "#060E16"))
}
