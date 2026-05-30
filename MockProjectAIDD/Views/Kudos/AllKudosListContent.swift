// AllKudosListContent.swift
// MockProjectAIDD
//
// Scrollable list content (or empty state) for the All Kudos screen.

import SwiftUI

// MARK: - AllKudosListContent

struct AllKudosListContent: View {
    let kudos: [Kudo]
    var onOpenKudo: (Kudo) -> Void
    var onLoadMore: () -> Void

    var body: some View {
        if kudos.isEmpty {
            AllKudosEmptyState()
        } else {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 12) {
                    ForEach(kudos) { kudo in
                        KudoCard(
                            kudo: kudo,
                            onCopyLink: nil,
                            onViewDetail: { openedKudo in
                                onOpenKudo(openedKudo)
                            }
                        )
                        // Load-more sentinel — attached only to the last kudo row so it
                        // fires exactly when that row appears, not on initial render of an
                        // empty-then-populated list, and never on non-terminal rows.
                        .onAppear {
                            if kudo.id == kudos.last?.id {
                                onLoadMore()
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
    }
}
