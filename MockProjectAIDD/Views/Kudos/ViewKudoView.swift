// ViewKudoView.swift
// MockProjectAIDD
//
// Detail view for a single Kudo — two visual states:
//   • Normal: sender identity shown (name + avatar + badge).
//   • Anonymous (ẩn danh): sender displayed as "Ẩn danh" / "Người gửi ẩn danh",
//     avatar replaced by a plain circle; identity is NEVER revealed.
//
// Anonymity contract: sender ONLY via `kudo.resolvedSender`. `kudo.isAnonymous`
// drives the display label. No direct access to the private `sender` field.
//
// Contract: ViewKudoView(kudo:onComment:onReact:)
// Presentational only — no service calls, no ViewModel ownership.
// Comment input uses local @State for field text; posting fires onComment callback.

import SwiftUI

// MARK: - ViewKudoView

struct ViewKudoView: View {
    let kudo: Kudo
    var onBack: (() -> Void)?
    /// Returns true when the comment was posted, so the field can clear (kept on failure).
    var onComment: (String) async -> Bool
    var onReact: () -> Void

    @State private var commentText: String = ""

    @Environment(\.dismiss) private var dismiss

    // Date formatter — static to avoid allocation per render
    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm - MM/dd/yyyy"
        return f
    }()

    private var formattedDate: String {
        Self.dateFormatter.string(from: kudo.createdAt)
    }

    private var hashtagsLine: String {
        kudo.hashtags.map(\.name).joined(separator: " ")
    }

    // The first hashtag title used as the kudo "title" (uppercased, no #)
    private var kudoTitle: String {
        guard let first = kudo.hashtags.first else { return "" }
        return first.name.uppercased().replacingOccurrences(of: "#", with: "")
    }

    var body: some View {
        ZStack(alignment: .top) {
            // Background: dark base colour
            Color.kudosDark.ignoresSafeArea()

            // Keyvisual background gradient overlay (matches Figma TopNavigation gradient)
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "00101A"), location: 0.0),
                    .init(color: Color(hex: "00101A").opacity(0.30), location: 0.7644),
                    .init(color: Color(hex: "00101A").opacity(0.20), location: 0.8462),
                    .init(color: Color(hex: "00101A").opacity(0.15), location: 0.8870),
                    .init(color: Color(hex: "00101A").opacity(0.10), location: 0.9279),
                    .init(color: Color(hex: "00101A").opacity(0.05), location: 0.9639),
                    .init(color: Color(hex: "00101A").opacity(0.00), location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity)
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top navigation bar (Figma: title "Kudo", back chevron)
                // onBack falls back to @Environment dismiss when caller provides none
                ViewKudoNavBar(onBack: onBack ?? { dismiss() })

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Main kudo highlight card
                        ViewKudoHighlightCard(
                            kudo: kudo,
                            formattedDate: formattedDate,
                            kudoTitle: kudoTitle,
                            hashtagsLine: hashtagsLine,
                            onReact: onReact
                        )

                        // Comments section (below card)
                        ViewKudoCommentsSection(
                            comments: kudo.comments,
                            commentText: $commentText,
                            onSubmit: {
                                let trimmed = commentText.trimmingCharacters(in: .whitespacesAndNewlines)
                                guard !trimmed.isEmpty else { return }
                                // Clear only after a successful post so a failed send keeps the text.
                                Task { if await onComment(trimmed) { commentText = "" } }
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100) // clear tab bar
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Previews

#Preview("View Kudo — Named sender") {
    ViewKudoView(
        kudo: .previewNamed,
        onComment: { _ in true },
        onReact: {}
    )
}

#Preview("View Kudo — Anonymous (ẩn danh)") {
    ViewKudoView(
        kudo: .previewAnonymous,
        onComment: { _ in true },
        onReact: {}
    )
}
