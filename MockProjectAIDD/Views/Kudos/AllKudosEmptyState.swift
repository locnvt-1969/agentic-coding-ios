// AllKudosEmptyState.swift
// MockProjectAIDD
//
// Empty state view shown when the All Kudos list has no items.

import SwiftUI

// MARK: - AllKudosEmptyState

struct AllKudosEmptyState: View {
    var body: some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: "heart.slash")
                .font(.system(size: 40))
                .foregroundStyle(Color.kudosBorderMuted)
            Text("Chưa có kudos nào")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color.kudosBorderMuted)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
