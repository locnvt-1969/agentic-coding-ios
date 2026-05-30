// SendKudoDropdowns.swift
// MockProjectAIDD
//
// Recipient and hashtag dropdown overlays for the Send Kudo compose form.
//
// WHY NOT reusing FilterOverlay directly:
//   - Recipient rows are 60px tall with avatar (40px circle) + name + department.
//     FilterOverlay rows are 40px text-only — genuinely different layout.
//   - Hashtag rows show a checkmark icon on already-selected items (multi-select).
//     FilterOverlay is single-select with bold/glow highlight — different semantics.
//   Both share the same container shell (dark #00070C bg, #998C5F border, 8px radius,
//   6px padding) so the shell is factored into DropdownShell below.
// Design source: screens 5MU728Tjck (recipient) + aKWA2klsnt (hashtag).

import SwiftUI

// MARK: - DropdownShell

private struct DropdownShell<Content: View>: View {
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content()
        }
        .padding(6)
        .frame(width: 311)
        .background(Color.kudosOverlayBg)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.kudosBorderMuted, lineWidth: 1)
        )
    }
}

// MARK: - SendKudoRecipientDropdown

/// Dropdown list for recipient search results.
/// Design: dark container, each row 60px — avatar (40px circle) + name/dept stack.
/// Selected row: #FFEA9E 20% highlight bg + rounded 2px.
struct SendKudoRecipientDropdown: View {
    let items: [User]
    var onSelect: (User) -> Void
    var onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Tap-outside dismiss layer — must be hit-testable (no .allowsHitTesting(false))
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { onDismiss() }

            DropdownShell {
                ForEach(items) { user in
                    RecipientDropdownRow(user: user, onTap: { onSelect(user) })
                }
            }
        }
    }
}

// MARK: - RecipientDropdownRow

private struct RecipientDropdownRow: View {
    let user: User
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 2) {
                // Avatar 40px circle with white border
                ZStack {
                    Circle()
                        .fill(Color(hex: "EEEEEE"))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(Color.white, lineWidth: 1.87)
                        )
                    if let url = user.avatarURL {
                        AsyncImage(url: url) { phase in
                            if let img = phase.image {
                                img.resizable().scaledToFill()
                            } else {
                                Color(hex: "EEEEEE")
                            }
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.kudosMuted)
                    }
                }
                .frame(width: 40, height: 40)
                .padding(10)

                // Name + department
                VStack(alignment: .leading, spacing: 0) {
                    Text(user.name)
                        .font(.custom("Montserrat", size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.white)
                        .lineLimit(1)
                        .tracking(0.1)

                    Text(user.departmentName ?? "")
                        .font(.custom("Montserrat", size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.kudosMuted)
                        .lineLimit(1)
                        .tracking(0.1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(width: 299, height: 60)
            // No persistent selected-state fill: recipient add is tap-and-dismiss,
            // not a persisted selection. Background stays clear until tapped.
            .background(Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - SendKudoHashtagDropdown

/// Dropdown list for hashtag multi-select.
/// Design: already-selected rows show a checkmark icon + #FFEA9E 20% highlight bg.
/// Unselected rows have no highlight and no checkmark.
struct SendKudoHashtagDropdown: View {
    let items: [Hashtag]
    let selectedHashtags: [Hashtag]
    var onSelect: (Hashtag) -> Void
    var onDismiss: () -> Void

    private var selectedIDs: Set<String> { Set(selectedHashtags.map(\.id)) }

    var body: some View {
        ZStack(alignment: .top) {
            // Tap-outside dismiss layer — mirrors RecipientDropdown pattern
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { onDismiss() }

            DropdownShell {
                ForEach(items) { hashtag in
                    HashtagDropdownRow(
                        hashtag: hashtag,
                        isSelected: selectedIDs.contains(hashtag.id),
                        onTap: { onSelect(hashtag) }
                    )
                }
            }
        }
    }
}

// MARK: - HashtagDropdownRow

private struct HashtagDropdownRow: View {
    let hashtag: Hashtag
    let isSelected: Bool
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 2) {
                // Leading space matching recipient avatar column width
                Color.clear.frame(width: 16)

                Text(hashtag.name)
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.white)
                    .lineLimit(1)
                    .tracking(0.1)
                    .frame(maxWidth: .infinity, alignment: .leading)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color.white)
                        .frame(width: 24, height: 24)
                }
            }
            .padding(.horizontal, 16)
            .frame(width: 299, height: 40)
            .background(isSelected ? Color.kudosAccent.opacity(0.2) : Color.clear)
            .clipShape(RoundedRectangle(cornerRadius: 2))
        }
        .buttonStyle(.plain)
    }
}

// Previews live in SendKudoView.swift (#Preview default + error state cover both dropdowns)
