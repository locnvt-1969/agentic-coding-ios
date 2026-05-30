// KudosSharedComponents.swift
// MockProjectAIDD
//
// Shared presentational sub-components for the Kudos board:
// KudosSectionHeader, KudosFilterButton, KudosEmptyState,
// KudosKeyVisualSection, KudosSendCTAButton.

import SwiftUI

// MARK: - KudosSectionHeader

struct KudosSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(subtitle)
                .font(.custom("Montserrat", size: 12))
                .fontWeight(.regular)
                .foregroundStyle(Color.white)
                .padding(.horizontal, 20)

            Rectangle()
                .fill(Color(hex: "2E3940"))
                .frame(maxWidth: .infinity)
                .frame(height: 1)
                .padding(.horizontal, 20)

            Text(title)
                .font(.custom("Montserrat", size: 22))
                .fontWeight(.medium)
                .foregroundStyle(Color.kudosAccent)
                .padding(.horizontal, 20)
        }
    }
}

// MARK: - KudosFilterButton

struct KudosFilterButton: View {
    let label: String
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(label)
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "chevron.down")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.white)
            }
            .padding(8)
            .frame(height: 40)
            .background(Color.kudosAccent.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.kudosBorderMuted, lineWidth: 1)
            )
        }
    }
}

// MARK: - KudosEmptyState

struct KudosEmptyState: View {
    let message: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.slash")
                .font(.system(size: 32))
                .foregroundStyle(Color.kudosBorderMuted)
            Text(message)
                .font(.custom("Montserrat", size: 14))
                .foregroundStyle(Color.kudosBorderMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
    }
}

// MARK: - KudosKeyVisualSection

struct KudosKeyVisualSection: View {
    var body: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [Color(hex: "00101A"), Color(hex: "001825")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 200)

            VStack(spacing: 4) {
                Text("Hệ thống ghi nhận và cảm ơn")
                    .font(.custom("Montserrat", size: 12))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.white.opacity(0.7))

                Text("KUDOS")
                    .font(.custom("Montserrat", size: 28))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.kudosAccent)
                    .tracking(4)
            }
            .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }
}

// MARK: - KudosSendCTAButton

struct KudosSendCTAButton: View {
    /// Called when the user taps the CTA. nil = button renders but tap is no-op.
    var onSendKudo: (() -> Void)? = nil

    var body: some View {
        Button {
            onSendKudo?()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(Color.kudosAccent)

                Text(" Hôm nay, bạn muốn gửi kudos đến ai?   ")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)

                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity)
            .background(Color.kudosAccent.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.kudosBorderMuted, lineWidth: 1)
            )
        }
    }
}

// MARK: - Previews

#Preview("KudosSectionHeader") {
    KudosSectionHeader(title: "HIGHLIGHT KUDOS", subtitle: "Sun* Annual Awards 2025")
        .background(Color(hex: "00101A"))
}

#Preview("KudosFilterButton") {
    KudosFilterButton(label: "Hashtag", onTap: {})
        .frame(width: 129)
        .padding()
        .background(Color(hex: "00101A"))
}

#Preview("KudosEmptyState") {
    KudosEmptyState(message: "Chưa có kudos nổi bật")
        .background(Color(hex: "00101A"))
}

#Preview("KudosKeyVisualSection") {
    KudosKeyVisualSection()
}

#Preview("KudosSendCTAButton") {
    KudosSendCTAButton(onSendKudo: {})
        .padding()
        .background(Color(hex: "00101A"))
}
