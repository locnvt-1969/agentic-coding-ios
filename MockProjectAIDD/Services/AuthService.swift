// AuthService.swift
// MockProjectAIDD
//
// Wraps Google OAuth via Supabase. All Supabase calls are stubbed
// until the Supabase Swift SDK is added via SPM.

import Foundation

enum AuthError: LocalizedError {
    case signInCancelled
    case signInFailed(String)

    var errorDescription: String? {
        switch self {
        case .signInCancelled: return nil
        case .signInFailed(let msg): return msg
        }
    }
}

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private(set) var isAuthenticated = false

    // MARK: - Session Restore (TC_LOGIN_ACC_002, TC_LOGIN_FUN_012)
    /// Returns true if a valid session exists; false means show Login screen.
    func checkAndRestoreSession() async -> Bool {
        // TODO: Replace with Supabase session check when SDK is installed:
        // guard let _ = try? await supabaseClient.auth.session else { return false }
        // isAuthenticated = true
        // return true
        return false
    }

    // MARK: - Google Sign In (TC_LOGIN_FUN_005)
    func signInWithGoogle() async throws {
        // TODO: Replace with Supabase Google OAuth when SDK is installed:
        // try await supabaseClient.auth.signInWithOAuth(
        //     provider: .google,
        //     redirectTo: URL(string: "com.mockprojectaidd://login-callback")
        // )
        // isAuthenticated = true
        throw AuthError.signInFailed("Google sign-in not yet configured. Add Supabase SDK via SPM.")
    }

    // MARK: - Sign Out
    func signOut() async {
        // TODO: try await supabaseClient.auth.signOut()
        isAuthenticated = false
    }
}
