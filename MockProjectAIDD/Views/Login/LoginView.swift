// LoginView.swift
// MockProjectAIDD
//
// Presentational login screen — no direct service calls.
// Layout (Figma positions, 375pt frame):
//   y:0-104    — LoginHeaderView (gradient + logo 48×44 + language dropdown)
//   y:252-361  — ROOT FURTHER image (247×109pt, left-aligned, x:20)
//   y:393-433  — Description text (left-aligned, x:20, Light 14pt)
//   y:626-666  — Login button (246pt wide, centered, x:65)
//   y:~782     — Copyright footer (centered, bottom)
//
// NOTE: Uses .background instead of ZStack to preserve safe area for content.
// ZStack with ignoresSafeArea child expands to full screen and pushes content
// behind the status bar. .background keeps the VStack within the safe area.

import SwiftUI

struct LoginView: View {
    // MARK: - Props (presentational)
    let selectedLanguage: AppLanguage
    let isLoading: Bool
    let onLoginWithGoogle: () async -> Void
    let onLanguageChange: (String) -> Void
    /// DEBUG-only: sign in with an explicit email/password to switch between seeded
    /// dev users. nil (and absent from the UI) in release builds.
    var onDevSignIn: ((String, String) async -> Void)? = nil

    #if DEBUG
    @State private var devEmail = "sunner@sun.com"
    @State private var devPassword = "Password123!"
    #endif

    var body: some View {
        VStack(spacing: 0) {
            // mms_2 + mms_2.1 — header: logo + language dropdown with dark gradient
            LoginHeaderView(
                selectedLanguage: selectedLanguage,
                onLanguageChange: { onLanguageChange($0.rawValue) }
            )

            Spacer()

            // mms_3 + mms_4 — ROOT FURTHER image + description (left-aligned)
            VStack(alignment: .leading, spacing: 32) {
                // mms_3 — ROOT FURTHER (247×109pt, x:20 in design)
                Image("logo-rootfuther")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 247, alignment: .leading)

                // mms_4 — localized description (Light 14pt, white, letterSpacing 0.25)
                Text(selectedLanguage.descriptionText)
                    .font(.system(size: 14, weight: .light))
                    .foregroundStyle(Color.white)
                    .tracking(0.25)
                    .lineSpacing(6)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 20)

            Spacer()

            // mms_5 — Login button (246pt wide: 65pt padding on each side)
            LoginGoogleButton(isLoading: isLoading) {
                Task { await onLoginWithGoogle() }
            }
            .padding(.horizontal, 65)

            #if DEBUG
            if let onDevSignIn {
                devLoginForm(onDevSignIn)
            }
            #endif

            // mms_6 — Copyright footer (centered, bottom)
            Text(selectedLanguage.copyrightText)
                .font(.system(size: 12, weight: .light))
                .foregroundStyle(Color.white.opacity(0.7))
                .padding(.top, 16)
                .padding(.bottom, 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            // ZStack + ignoresSafeArea covers all safe areas (status bar + home indicator)
            // Color.black prevents the white system window background from bleeding through
            ZStack {
                Color.black
                Image("keyvisual-bg")
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()
        )
    }

    #if DEBUG
    /// Local dev-only credential form. All seeded users share password `Password123!`
    /// (sunner@sun.com, buddy@sun.com, dir1..20@dev.sun.com) — edit the email to switch.
    @ViewBuilder
    private func devLoginForm(_ action: @escaping (String, String) async -> Void) -> some View {
        VStack(spacing: 8) {
            Text("DEV LOGIN — switch seeded user")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.yellow.opacity(0.85))

            TextField("email", text: $devEmail)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundStyle(.black)
                .padding(8)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            SecureField("password", text: $devPassword)
                .foregroundStyle(.black)
                .padding(8)
                .background(Color.white.opacity(0.92))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Button {
                Task { await action(devEmail, devPassword) }
            } label: {
                Text("Dev Sign In")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .padding(10)
                    .background(Color.yellow.opacity(0.85))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            .disabled(isLoading)
        }
        .font(.system(size: 13))
        .padding(.horizontal, 40)
        .padding(.top, 16)
    }
    #endif
}

#Preview {
    LoginView(
        selectedLanguage: .vn,
        isLoading: false,
        onLoginWithGoogle: {},
        onLanguageChange: { _ in }
    )
}
