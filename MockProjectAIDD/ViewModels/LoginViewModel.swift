// LoginViewModel.swift
// MockProjectAIDD

import Observation
import SwiftUI

@MainActor
@Observable
final class LoginViewModel {

    // Language persisted in UserDefaults (TC_LOGIN_FUN_003, persistence requirement)
    var selectedLanguageCode: String = UserDefaults.standard.string(forKey: "selectedLanguageCode") ?? AppLanguage.vn.rawValue {
        didSet { UserDefaults.standard.set(selectedLanguageCode, forKey: "selectedLanguageCode") }
    }

    var selectedLanguage: AppLanguage {
        AppLanguage(rawValue: selectedLanguageCode) ?? .vn
    }

    var isLoading = false
    var showError = false
    var errorMessage: String?
    var isAuthenticated = false

    // Double-click prevention (TC_LOGIN_FUN_008)
    private var isInFlight = false

    func loginWithGoogle() async {
        guard !isInFlight else { return }
        isInFlight = true
        isLoading = true
        errorMessage = nil
        defer {
            isInFlight = false
            isLoading = false
        }
        do {
            try await AuthService.shared.signInWithGoogle()
            isAuthenticated = true
        } catch AuthError.signInCancelled {
            // Silent — user dismissed the OAuth sheet
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }

    #if DEBUG
    /// DEV-only: sign in with an explicit email/password to switch seeded users.
    func devSignIn(email: String, password: String) async {
        guard !isInFlight else { return }
        isInFlight = true
        isLoading = true
        errorMessage = nil
        defer {
            isInFlight = false
            isLoading = false
        }
        do {
            try await AuthService.shared.signIn(email: email, password: password)
            isAuthenticated = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
    #endif

    func changeLanguage(to language: AppLanguage) {
        selectedLanguageCode = language.rawValue
    }
}
