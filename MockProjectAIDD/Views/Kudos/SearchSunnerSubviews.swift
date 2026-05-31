// SearchSunnerSubviews.swift
// MockProjectAIDD
//
// Sub-components used by SearchSunnerView:
//   - SearchSunnerBackground: decorative keyvisual layer
//   - SearchRecentRow: idle-state row with a remove (×) button
//   - SearchEmptyResults: empty state when query returns nothing
// All purely presentational — no service calls, no state ownership.

import SwiftUI

// MARK: - SearchSunnerBackground

/// Dark base + right-side key visual image from Figma (mm_media_bg group).
struct SearchSunnerBackground: View {
    var body: some View {
        ZStack {
            Color(hex: "00101A")
                .ignoresSafeArea()

            Image("SearchKeyvisualBG")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity, maxHeight: 723)
                .clipped()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                .ignoresSafeArea()
                .allowsHitTesting(false)
        }
    }
}

// MARK: - SearchRecentRow

/// Idle-state row: user info + trailing × button (Figma: mm_media_close 16x16).
struct SearchRecentRow: View {
    let user: User
    let onSelect: () -> Void
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            SunnerResultRow(user: user, onTap: onSelect)
            Spacer()
            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(Color.white)
                    .frame(width: 16, height: 16)
            }
        }
        .padding(.horizontal, 20)
        .frame(height: 60)
    }
}

// MARK: - SearchEmptyResults

/// Shown when query is non-empty and results list is empty (not loading).
struct SearchEmptyResults: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "person.slash")
                .font(.system(size: 28))
                .foregroundStyle(Color(hex: "999999"))
            Text("No sunners found")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "999999"))
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 48)
    }
}

// MARK: - Previews

#Preview("SearchSunnerBackground") {
    SearchSunnerBackground()
}

#Preview("SearchRecentRow") {
    SearchRecentRow(
        user: User(id: "u1", name: "Dương Huỳnh Xuân Nhật", departmentName: "CECV1"),
        onSelect: {},
        onRemove: {}
    )
    .background(Color(hex: "00101A"))
}

#Preview("SearchEmptyResults") {
    ZStack {
        Color(hex: "00101A").ignoresSafeArea()
        SearchEmptyResults()
    }
}
