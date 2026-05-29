// LoginHeaderView.swift
// MockProjectAIDD
//
// Header: logo (48×44pt, left) + language dropdown (right)
// Dark-to-transparent gradient background extends behind status bar.
// mms_2_mm_media_logo + mms_2.1_language

import SwiftUI

struct LoginHeaderView: View {
    let selectedLanguage: AppLanguage
    let onLanguageChange: (AppLanguage) -> Void

    var body: some View {
        HStack(alignment: .center) {
            // mms_2_mm_media_logo — 48×44pt, top-left (x:20, y:52 in design)
            Image("logo-homepage")
                .resizable()
                .scaledToFit()
                .frame(width: 48, height: 44)

            Spacer()

            // mms_2.1_language — custom dropdown overlay, top-right
            LanguageDropdownView(
                selectedLanguage: selectedLanguage.rawValue,
                onLanguageChange: { code in
                    if let lang = AppLanguage(rawValue: code) {
                        onLanguageChange(lang)
                    }
                }
            )
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(
            // Gradient: #00101A → transparent (matches header node gradient)
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "#00101A"), location: 0),
                    .init(color: Color(hex: "#00101A").opacity(0.30), location: 0.7644),
                    .init(color: Color(hex: "#00101A").opacity(0.20), location: 0.8462),
                    .init(color: Color(hex: "#00101A").opacity(0.10), location: 0.9279),
                    .init(color: .clear, location: 1.0)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
    }
}

#Preview {
    LoginHeaderView(selectedLanguage: .vn, onLanguageChange: { _ in })
        .background(Color(hex: "#1A2A3A"))
}
