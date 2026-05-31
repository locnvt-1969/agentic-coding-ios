// AccessDeniedView.swift
// MockProjectAIDD
//
// Thin wrapper over ErrorView for the 403 Access Denied screen.
// Presentational only — passes .accessDenied kind and surfaces onGoHome callback.

import SwiftUI

struct AccessDeniedView: View {
    let onGoHome: () -> Void

    var body: some View {
        ErrorView(kind: .accessDenied, onPrimaryAction: onGoHome)
    }
}

#Preview("403 Access Denied") {
    AccessDeniedView(onGoHome: {})
}
