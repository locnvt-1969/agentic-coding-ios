// LoginContainerView.swift
// MockProjectAIDD
//
// Wires LoginViewModel state into the presentational LoginView.
// Owns error alert (TC_LOGIN_FUN_010) and startup session restore (TC_LOGIN_ACC_002).

import SwiftUI

struct LoginContainerView: View {
    @State private var viewModel = LoginViewModel()
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        LoginView(
            selectedLanguage: viewModel.selectedLanguage,
            isLoading: viewModel.isLoading,
            onLoginWithGoogle: {
                await viewModel.loginWithGoogle()
            },
            onLanguageChange: { code in
                if let lang = AppLanguage(rawValue: code) {
                    viewModel.changeLanguage(to: lang)
                }
            }
        )
        // Error alert — TC_LOGIN_FUN_010 (SwiftUI .alert per spec decision)
        .alert("Sign In Failed", isPresented: $viewModel.showError) {
            Button("OK") {}
        } message: {
            Text(viewModel.errorMessage ?? "An error occurred. Please try again.")
        }
        // Startup session restore — TC_LOGIN_ACC_002, TC_LOGIN_FUN_012
        .task {
            let hasSession = await AuthService.shared.checkAndRestoreSession()
            if hasSession { router.navigate(to: .home) }
        }
        // Navigate to Home after successful login
        .onChange(of: viewModel.isAuthenticated) { _, isAuth in
            if isAuth { router.navigate(to: .home) }
        }
    }
}

#Preview {
    LoginContainerView()
        .environmentObject(AppRouter())
}
