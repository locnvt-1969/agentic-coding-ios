// SendKudoAuxRows.swift
// MockProjectAIDD
//
// Auxiliary rows for the Send Kudo compose form:
//   - SendKudoImageRow      — static image upload strip (presentational)
//   - SendKudoAnonymousRow  — anonymous toggle (checkbox style from Figma)
//
// Design source: screen 7fFAb-K35a (default state).
// All values sourced from Figma — no guessing.

import SwiftUI

// MARK: - SendKudoImageRow

/// Static image attachment row.
/// Shows "Image" label + 5 placeholder image slots (32×32 rounded) + upload button.
/// Upload action wired in SendKudoViewModel (phase-19); row is presentational here.
struct SendKudoImageRow: View {
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Label "Image" — 14px Montserrat regular, kudosDark
            Text("Image")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.regular)
                .foregroundStyle(Color.kudosDark)
                .frame(width: 46, alignment: .leading)
                .padding(.top, 9)

            VStack(alignment: .leading, spacing: 8) {
                // 5 placeholder image slots
                HStack(spacing: 4) {
                    ForEach(0..<5, id: \.self) { _ in
                        RoundedRectangle(cornerRadius: 8.04)
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8.04)
                                    .stroke(Color.kudosBorderMuted, lineWidth: 0.447)
                            )
                    }
                }

                // Upload button
                Button(action: {}) {
                    HStack(spacing: 1.787) {
                        Image(systemName: "plus")
                            .font(.system(size: 12))
                            .foregroundStyle(Color.kudosBorderMuted)
                            .frame(width: 16, height: 16)

                        Text("Upload image")
                            .font(.custom("Montserrat", size: 12))
                            .fontWeight(.regular)
                            .foregroundStyle(Color.kudosBorderMuted)
                    }
                    .padding(.horizontal, 3.574)
                    .padding(.vertical, 1.787)
                    .frame(height: 32)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 3.574))
                    .overlay(
                        RoundedRectangle(cornerRadius: 3.574)
                            .stroke(Color.kudosBorderMuted, lineWidth: 0.447)
                    )
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(height: 72)
    }
}

// MARK: - SendKudoAnonymousRow

/// "Gửi ẩn danh" toggle row.
/// Uses a custom checkbox that mirrors the Figma square checkbox (24×24, white fill,
/// #998C5F 1px stroke, 4px radius). Checked state shows a system checkmark inside.
struct SendKudoAnonymousRow: View {
    @Binding var isAnonymous: Bool

    var body: some View {
        HStack(spacing: 8) {
            // Custom checkbox
            Button(action: { isAnonymous.toggle() }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white)
                        .frame(width: 24, height: 24)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .stroke(Color.kudosBorderMuted, lineWidth: 1)
                        )

                    if isAnonymous {
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(Color.kudosDark)
                    }
                }
            }
            .buttonStyle(.plain)

            // Label — 12px Montserrat regular, #999999
            Text("Gửi lời cám ơn và ghi nhận ẩn danh")
                .font(.custom("Montserrat", size: 12))
                .fontWeight(.regular)
                .foregroundStyle(Color.kudosMuted)
        }
        .frame(height: 24)
    }
}

// MARK: - Previews

#Preview("ImageRow") {
    SendKudoImageRow()
        .padding()
        .background(Color.kudosBackground)
}

#Preview("AnonymousRow") {
    SendKudoAnonymousRow(isAnonymous: .constant(false))
        .padding()
        .background(Color.kudosBackground)
}
