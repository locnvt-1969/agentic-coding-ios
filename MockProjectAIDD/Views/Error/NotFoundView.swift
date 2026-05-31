// NotFoundView.swift
// MockProjectAIDD
//
// Thin wrapper over ErrorView for the 404 Not Found screen.
// Presentational only — passes .notFound kind and surfaces onGoHome callback.

import SwiftUI

struct NotFoundView: View {
    let onGoHome: () -> Void

    var body: some View {
        ErrorView(kind: .notFound, onPrimaryAction: onGoHome)
    }
}

#Preview("404 Not Found") {
    NotFoundView(onGoHome: {})
}
