// ToastBannerView.swift
// MockProjectAIDD
//
// App-level toast overlay. Reads ToastCenter.shared.message and renders
// a dark capsule at top-center. Mount once in MockProjectAIDDApp ZStack.

import SwiftUI

struct ToastBannerView: View {

    @State private var toast = ToastCenter.shared

    var body: some View {
        VStack {
            if let message = toast.message {
                Text(message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        Capsule()
                            .fill(Color(white: 0.12).opacity(0.96))
                            .shadow(color: .black.opacity(0.4), radius: 8, x: 0, y: 4)
                    )
                    .transition(.opacity.combined(with: .move(edge: .top)))
                    .padding(.top, 56)
            }
            Spacer()
        }
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: toast.message)
        .allowsHitTesting(false)
    }
}

#Preview {
    ZStack {
        Color(hex: "#040D14").ignoresSafeArea()
        ToastBannerView()
    }
}
