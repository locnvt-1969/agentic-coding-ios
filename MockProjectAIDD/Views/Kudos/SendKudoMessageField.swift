// SendKudoMessageField.swift
// MockProjectAIDD
//
// Compose message area for the Send Kudo form.
// Toolbar (Bold/Italic/Strike/Number/Link/Quote/Preview) + multi-line text area.
// Design: #998C5F border, 0.447px stroke, white bg, 3.574px radius.
// Presentational only — no business logic.

import SwiftUI

// MARK: - SendKudoMessageField

struct SendKudoMessageField: View {
    @Binding var message: String

    var body: some View {
        VStack(alignment: .leading, spacing: 1.787) {
            // Toolbar row
            MessageToolbar()

            // Text area
            ZStack(alignment: .topLeading) {
                TextEditor(text: $message)
                    .font(.custom("Montserrat", size: 12))
                    .foregroundStyle(Color.kudosDark)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: 89)

                if message.isEmpty {
                    Text("Nhập nội dung Kudo của bạn...")
                        .font(.custom("Montserrat", size: 12))
                        .foregroundStyle(Color.kudosMuted)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                        .allowsHitTesting(false)
                }
            }
            .padding(8)
            .frame(minHeight: 89)
            .background(Color.white)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 3.574,
                    bottomTrailingRadius: 3.574,
                    topTrailingRadius: 0
                )
            )
            .overlay(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 3.574,
                    bottomTrailingRadius: 3.574,
                    topTrailingRadius: 0
                )
                .stroke(Color.kudosBorderMuted, lineWidth: 0.447)
            )

            // Hint
            Text("Bạn có thể \"@ + tên\" để nhắc tới đồng nghiệp khác")
                .font(.custom("Montserrat", size: 10))
                .fontWeight(.regular)
                .foregroundStyle(Color.kudosMuted)
        }
    }
}

// MARK: - MessageToolbar

private struct MessageToolbar: View {
    private let tools: [(icon: String, label: String)] = [
        ("bold", "B"),
        ("italic", "I"),
        ("strikethrough", "S"),
        ("list.number", "1"),
        ("link", "L"),
        ("text.quote", "Q")
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(tools.enumerated()), id: \.offset) { index, tool in
                ToolbarButton(systemName: tool.icon, isFirst: index == 0)
            }
            // Preview button — flex fill
            Spacer(minLength: 0)
            HStack(spacing: 3.574) {
                Image(systemName: "eye")
                    .font(.system(size: 11))
                Text("Preview")
                    .font(.custom("Montserrat", size: 11))
                    .fontWeight(.regular)
            }
            .foregroundStyle(Color.kudosDark)
            .padding(.horizontal, 7.15)
            .padding(.vertical, 4.47)
            .frame(maxWidth: .infinity)
            .background(Color.clear)
            .overlay(
                Rectangle()
                    .stroke(Color.kudosBorderMuted, lineWidth: 0.447)
            )
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 3.574,
                    topTrailingRadius: 3.574
                )
            )
        }
        .frame(height: 24)
    }
}

// MARK: - ToolbarButton

private struct ToolbarButton: View {
    let systemName: String
    let isFirst: Bool

    var body: some View {
        Button(action: {}) {
            Image(systemName: systemName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color.kudosDark)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(.plain)
        .background(Color.clear)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: isFirst ? 3.574 : 0,
                bottomLeadingRadius: 0,
                bottomTrailingRadius: 0,
                topTrailingRadius: 0
            )
        )
        .overlay(
            Rectangle()
                .stroke(Color.kudosBorderMuted, lineWidth: 0.447)
        )
    }
}
