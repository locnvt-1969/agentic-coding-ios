// SendKudoHashtagRow.swift
// MockProjectAIDD
//
// Hashtag field row for the Send Kudo form.
// Shows selected hashtag chips (removable) + "Hashtag (Tối đa 5)" add button.
// Design: pill chips with #998C5F border, 3.574px radius, white bg.
// Presentational only.

import SwiftUI

// MARK: - SendKudoHashtagRow

struct SendKudoHashtagRow: View {
    let selectedHashtags: [Hashtag]
    let availableHashtags: [Hashtag]
    var onRemove: (Hashtag) -> Void
    var onTapAdd: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Label
            HStack(alignment: .top, spacing: 1) {
                Text("Hashtag")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.kudosDark)
                Text("*")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(hex: "CF1322"))
                    .baselineOffset(4)
            }
            .frame(width: 82, alignment: .leading)
            .padding(.top, 7)

            // Tag group — wrapping chips + add button
            SendKudoTagGroup(
                selectedHashtags: selectedHashtags,
                onRemove: onRemove,
                onTapAdd: onTapAdd
            )
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - SendKudoTagGroup

struct SendKudoTagGroup: View {
    let selectedHashtags: [Hashtag]
    var onRemove: (Hashtag) -> Void
    var onTapAdd: () -> Void

    var body: some View {
        // Wrap chips using a flow-layout approach via VStack of HStacks
        VStack(alignment: .leading, spacing: 4) {
            // Selected chips (each row wraps when needed)
            ForEach(rowsOf(selectedHashtags, maxPerRow: 2), id: \.self) { row in
                HStack(spacing: 4) {
                    ForEach(row) { tag in
                        HashtagChip(name: tag.name, onRemove: { onRemove(tag) })
                    }
                }
            }

            // Add button (always shown unless max 5 reached)
            if selectedHashtags.count < 5 {
                HashtagAddButton(onTap: onTapAdd)
            }
        }
    }

    // Split array into rows of maxPerRow for chip wrapping
    private func rowsOf(_ items: [Hashtag], maxPerRow: Int) -> [[Hashtag]] {
        stride(from: 0, to: items.count, by: maxPerRow).map {
            Array(items[$0..<min($0 + maxPerRow, items.count)])
        }
    }
}

// MARK: - HashtagChip

struct HashtagChip: View {
    let name: String
    var onRemove: () -> Void

    var body: some View {
        HStack(spacing: 3.574) {
            Text(name)
                .font(.custom("Montserrat", size: 12))
                .fontWeight(.regular)
                .foregroundStyle(Color.kudosBorderMuted)
                .lineLimit(1)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color.kudosBorderMuted)
                    .frame(width: 16, height: 16)
            }
            .buttonStyle(.plain)
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
}

// MARK: - HashtagAddButton

struct HashtagAddButton: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 1.787) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.kudosDark)
                    .frame(width: 16, height: 16)

                Text("Hashtag (Tối đa 5)")
                    .font(.custom("Montserrat", size: 12))
                    .fontWeight(.regular)
                    .foregroundStyle(Color.kudosDark)
                    .lineLimit(1)
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
}
