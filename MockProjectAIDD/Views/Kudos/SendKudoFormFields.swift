// SendKudoFormFields.swift
// MockProjectAIDD
//
// Reusable field components for the Send Kudo compose form:
//   - SendKudoFieldRow   — labelled row (label left, input right) matching Figma label/input split
//   - SendKudoSearchField — white input pill with magnifying glass icon
//
// Design source: screen 7fFAb-K35a.
// Label column 94px, input column 210px, row height 40px.
// Border: #998C5F 0.447px, cornerRadius 3.574px (from Figma specs).

import SwiftUI

// MARK: - SendKudoFieldRow

struct SendKudoFieldRow<Content: View>: View {
    let label: String
    let isRequired: Bool
    @ViewBuilder let content: () -> Content

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            // Label + optional required asterisk
            HStack(alignment: .top, spacing: 1) {
                Text(label)
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.kudosDark)
                if isRequired {
                    Text("*")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color(hex: "CF1322"))
                        .baselineOffset(4)
                }
            }
            .frame(width: 94, alignment: .leading)

            Spacer()

            // Input — 210px wide matching Figma
            content()
                .frame(width: 210)
        }
        .frame(height: 40)
    }
}

// MARK: - SendKudoSearchField

struct SendKudoSearchField: View {
    let placeholder: String
    @Binding var text: String
    /// Optional: if provided, the whole field behaves as a tap target (shows dropdown).
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: { onTap?() }) {
            HStack {
                Text(text.isEmpty ? placeholder : text)
                    .font(.custom("Montserrat", size: 12))
                    .fontWeight(.regular)
                    .foregroundStyle(text.isEmpty ? Color.kudosMuted : Color.kudosDark)
                    .lineLimit(1)
                Spacer()
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.kudosMuted)
                    .frame(width: 24, height: 24)
            }
            .padding(.horizontal, 10.72)
            .padding(.vertical, 7.15)
            .frame(width: 210, height: 40)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 3.574))
            .overlay(
                RoundedRectangle(cornerRadius: 3.574)
                    .stroke(Color.kudosBorderMuted, lineWidth: 0.447)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SendKudoTextField

/// Editable single-line text input matching the search-field styling (no magnifier).
/// Used for the "Danh hiệu" (title) field — spec B.4 (text_form, editable).
struct SendKudoTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(.custom("Montserrat", size: 12))
                    .foregroundStyle(Color.kudosMuted)
                    .lineLimit(1)
                    .allowsHitTesting(false)
            }
            TextField("", text: $text)
                .font(.custom("Montserrat", size: 12))
                .foregroundStyle(Color.kudosDark)
                .tint(Color.kudosDark)
                .lineLimit(1)
        }
        .padding(.horizontal, 10.72)
        .padding(.vertical, 7.15)
        .frame(width: 210, height: 40)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 3.574))
        .overlay(
            RoundedRectangle(cornerRadius: 3.574)
                .stroke(Color.kudosBorderMuted, lineWidth: 0.447)
        )
    }
}
