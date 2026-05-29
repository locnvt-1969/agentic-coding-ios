// LoginGoogleButton.swift
// MockProjectAIDD
//
// mms_5_Button — golden (#FFEA9E) background, dark navy text, radius 4pt, height 40pt

import SwiftUI

struct LoginGoogleButton: View {
    let isLoading: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(Color(hex: "#00101A"))
                        .scaleEffect(0.85)
                } else {
                    Text("LOGIN With Google")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(hex: "#00101A"))

                    Image("google-icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: "#FFEA9E"))
            )
        }
        .disabled(isLoading)
        .opacity(isLoading ? 0.7 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isLoading)
    }
}

#Preview {
    VStack(spacing: 20) {
        LoginGoogleButton(isLoading: false, onTap: {})
        LoginGoogleButton(isLoading: true, onTap: {})
    }
    .padding(.horizontal, 65)
    .frame(maxWidth: .infinity)
    .background(Color(hex: "#00101A"))
}
