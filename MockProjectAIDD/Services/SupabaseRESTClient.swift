// SupabaseRESTClient.swift
// MockProjectAIDD
//
// Thin reusable PostgREST client (generalises the AwardsService pattern).
// Used by the data services to read/write the local Supabase instance over REST.
// Auth: currently sends the anon key. When real sessions land (auth phase),
// `accessToken` should carry the user JWT so RLS sees auth.uid().

import Foundation

enum SupabaseRESTError: LocalizedError {
    case invalidURL
    case network(String)
    case serverStatus(Int, String)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:                 return "URL không hợp lệ."
        case .network(let m):             return "Lỗi mạng: \(m)"
        case .serverStatus(let c, _):     return "Máy chủ trả về lỗi \(c)."
        case .decoding:                   return "Không thể đọc dữ liệu từ máy chủ."
        }
    }
}

/// An `actor` so HTTP + JSON decoding run off the main thread and `accessToken`
/// (set later by the auth phase) is mutated/read serially without data races.
actor SupabaseRESTClient {
    static let shared = SupabaseRESTClient()
    private init() {}

    private let session = URLSession.shared

    /// User access token once authenticated; falls back to the anon key for public reads.
    var accessToken: String?

    func setAccessToken(_ token: String?) { accessToken = token }

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - GET (PostgREST table/view)

    /// GET `restURL/<path>?<query>` and decode the JSON body to `T`.
    func get<T: Decodable>(_ path: String, query: [URLQueryItem] = [], as type: T.Type) async throws -> T {
        guard var components = URLComponents(
            url: SupabaseConfig.restURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else { throw SupabaseRESTError.invalidURL }
        components.queryItems = query.isEmpty ? nil : query
        guard let url = components.url else { throw SupabaseRESTError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        applyHeaders(&request)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw SupabaseRESTError.network(error.localizedDescription)
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw SupabaseRESTError.serverStatus(http.statusCode, String(data: data, encoding: .utf8) ?? "")
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw SupabaseRESTError.decoding(error.localizedDescription)
        }
    }

    // MARK: - Headers

    private func applyHeaders(_ request: inout URLRequest) {
        let bearer = accessToken ?? SupabaseConfig.anonKey
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    }
}
