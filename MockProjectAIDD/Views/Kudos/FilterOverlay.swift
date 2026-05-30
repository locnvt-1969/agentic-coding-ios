// FilterOverlay.swift
// MockProjectAIDD
//
// Generic dropdown filter overlay for Sun*Kudos board.
// Replaces HashtagFilterOverlay + DepartmentFilterOverlay — no duplicated layout code.
// Design: dark container (#00070C), border #998C5F, 8px radius.
// Selected row: highlighted bg + bold white glow text.
// Presentational only: no service calls.

import SwiftUI

// MARK: - FilterOverlay

struct FilterOverlay<Item: Identifiable>: View {
    let items: [Item]
    let selectedID: Item.ID?
    let labelKeyPath: KeyPath<Item, String>
    var onSelect: (Item) -> Void
    var onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(items) { item in
                FilterOverlayRow(
                    label: item[keyPath: labelKeyPath],
                    isSelected: selectedID == item.id,
                    onTap: { onSelect(item) }
                )
            }
        }
        .padding(6)
        .frame(width: 129)
        .background(Color.kudosOverlayBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.kudosBorderMuted, lineWidth: 1)
        )
    }
}

// MARK: - FilterOverlayRow

private struct FilterOverlayRow: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                Text(label)
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(isSelected ? .bold : .medium)
                    .foregroundStyle(Color.white)
                    .shadow(
                        color: isSelected ? Color(hex: "FAE287") : .clear,
                        radius: isSelected ? 3 : 0
                    )
                    .lineLimit(1)
                Spacer()
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 4)
            .frame(width: 117, height: 40)
            .background(isSelected ? Color.kudosAccent.opacity(0.1) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Preview

#Preview("FilterOverlay - Hashtags") {
    let hashtags = [
        Hashtag(id: "h1", name: "#Dedicated", group: nil),
        Hashtag(id: "h2", name: "#Inspiring", group: nil),
        Hashtag(id: "h3", name: "#TeamPlayer", group: nil)
    ]
    ZStack {
        Color(hex: "00101A").ignoresSafeArea()
        FilterOverlay(
            items: hashtags,
            selectedID: hashtags.first?.id,
            labelKeyPath: \.name,
            onSelect: { _ in },
            onDismiss: {}
        )
        .padding()
    }
}

#Preview("FilterOverlay - Departments") {
    let departments = [
        Department(id: "d1", name: "CEVC2"),
        Department(id: "d2", name: "CEVC3"),
        Department(id: "d3", name: "OPD")
    ]
    ZStack {
        Color(hex: "00101A").ignoresSafeArea()
        FilterOverlay(
            items: departments,
            selectedID: departments.first?.id,
            labelKeyPath: \.name,
            onSelect: { _ in },
            onDismiss: {}
        )
        .padding()
    }
}
