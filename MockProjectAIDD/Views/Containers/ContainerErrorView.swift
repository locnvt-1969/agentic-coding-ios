// ContainerErrorView.swift
// MockProjectAIDD
//
// Reusable error state for gated containers. Presentational only.
// Phase-19 integration fix.

import SwiftUI

struct ContainerErrorView: View {
    let message: String
    let onRetry: () -> Void
    let onBack: (() -> Void)?

    init(message: String, onRetry: @escaping () -> Void, onBack: (() -> Void)? = nil) {
        self.message = message
        self.onRetry = onRetry
        self.onBack = onBack
    }

    var body: some View {
        ZStack {
            Color(hex: "00101A").ignoresSafeArea()
            VStack(spacing: 24) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.system(size: 44))
                    .foregroundStyle(.white.opacity(0.7))
                Text(message)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                HStack(spacing: 16) {
                    if let onBack {
                        Button("Quay lại", action: onBack)
                            .buttonStyle(ContainerErrorSecondaryButtonStyle())
                    }
                    Button("Thử lại", action: onRetry)
                        .buttonStyle(ContainerErrorPrimaryButtonStyle())
                }
            }
        }
    }
}

private struct ContainerErrorPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.black)
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .background(Color.white.opacity(configuration.isPressed ? 0.8 : 1))
            .clipShape(Capsule())
    }
}

private struct ContainerErrorSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white.opacity(configuration.isPressed ? 0.6 : 0.85))
            .padding(.horizontal, 28)
            .padding(.vertical, 12)
            .overlay(Capsule().stroke(Color.white.opacity(0.4), lineWidth: 1))
    }
}
