// AuthService.swift
// MockProjectAIDD
//
// Auth boundary. Local dev uses GoTrue email/password (raw REST) to obtain a real
// session, then sets the JWT on SupabaseRESTClient so RLS sees auth.uid().
// Real Google OAuth is a production follow-up (Supabase SDK).

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

private struct AuthSessionDTO: Decodable {
    let accessToken: String
    let refreshToken: String
    let user: AuthUser
    struct AuthUser: Decodable { let id: String }
}

@MainActor
final class AuthService {
    static let shared = AuthService()
    private init() {}

    private(set) var isAuthenticated = false
    private(set) var currentUserId: String?

    // DEV (local): seeded test account. Real Google OAuth = production follow-up (SDK).
    private let devEmail = "sunner@sun.com"
    private let devPassword = "Password123!"

    private enum StoreKey {
        static let token = "sb_access_token"
        static let refresh = "sb_refresh_token"
        static let userId = "sb_user_id"
    }

    private let session = URLSession.shared
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - Session restore (TC_LOGIN_ACC_002)

    /// Restore a persisted session (dev: no expiry check — re-login if the JWT lapsed).
    func checkAndRestoreSession() async -> Bool {
        let defaults = UserDefaults.standard
        guard let token = defaults.string(forKey: StoreKey.token), !token.isEmpty,
              let uid = defaults.string(forKey: StoreKey.userId) else { return false }
        currentUserId = uid
        isAuthenticated = true
        await SupabaseRESTClient.shared.setAccessToken(token)
        return true
    }

    // MARK: - Sign in

    /// DEV: signs in the seeded test user via email/password.
    /// TODO: replace with real Supabase Google OAuth (SDK) for production.
    func signInWithGoogle() async throws {
        try await signIn(email: devEmail, password: devPassword)
    }

    func signIn(email: String, password: String) async throws {
        guard var components = URLComponents(
            url: SupabaseConfig.authURL.appendingPathComponent("token"),
            resolvingAgainstBaseURL: false
        ) else { throw AuthError.signInFailed("Invalid auth URL") }
        components.queryItems = [URLQueryItem(name: "grant_type", value: "password")]
        guard let url = components.url else { throw AuthError.signInFailed("Invalid auth URL") }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: ["email": email, "password": password])

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw AuthError.signInFailed("Đăng nhập thất bại (\(http.statusCode)).")
        }
        let dto: AuthSessionDTO
        do {
            dto = try decoder.decode(AuthSessionDTO.self, from: data)
        } catch {
            throw AuthError.signInFailed(error.localizedDescription)
        }

        let defaults = UserDefaults.standard
        defaults.set(dto.accessToken, forKey: StoreKey.token)
        // TODO: use refresh token for silent re-auth (refresh_token grant) — not yet implemented.
        defaults.set(dto.refreshToken, forKey: StoreKey.refresh)
        defaults.set(dto.user.id, forKey: StoreKey.userId)
        currentUserId = dto.user.id
        isAuthenticated = true
        await SupabaseRESTClient.shared.setAccessToken(dto.accessToken)
    }

    // MARK: - Sign out

    func signOut() async {
        let defaults = UserDefaults.standard
        [StoreKey.token, StoreKey.refresh, StoreKey.userId].forEach(defaults.removeObject(forKey:))
        currentUserId = nil
        isAuthenticated = false
        await SupabaseRESTClient.shared.setAccessToken(nil)
    }
}
