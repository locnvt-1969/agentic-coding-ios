// SupabaseRESTClient.swift
// MockProjectAIDD
//
// Thin reusable PostgREST client (generalises the AwardsService pattern).
// An `actor` so HTTP + JSON decoding run off the main thread and `accessToken`
// (set by AuthService after sign-in) is mutated/read serially without data races.
// Auth: sends the user JWT once set, else the anon key for public reads.

import Foundation

enum SupabaseRESTError: LocalizedError {
    case invalidURL
    case network(String)
    case serverStatus(Int, String)
    case decoding(String)

    var errorDescription: String? {
        switch self {
        case .invalidURL:             return "URL không hợp lệ."
        case .network(let m):         return "Lỗi mạng: \(m)"
        case .serverStatus(let c, _): return "Máy chủ trả về lỗi \(c)."
        case .decoding:               return "Không thể đọc dữ liệu từ máy chủ."
        }
    }
}

actor SupabaseRESTClient {
    static let shared = SupabaseRESTClient()
    private init() {}

    private let session = URLSession.shared

    /// User access token once authenticated; falls back to the anon key for public reads.
    private var accessToken: String?
    func setAccessToken(_ token: String?) { accessToken = token }

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    // MARK: - GET (table/view)

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
        return try await send(request)
    }

    // MARK: - RPC (POST /rpc/<name>)

    /// Call a Postgres function via PostgREST and decode the returned JSON to `T`.
    func callRPC<T: Decodable>(_ name: String, body: [String: Any] = [:], as type: T.Type) async throws -> T {
        let url = SupabaseConfig.restURL.appendingPathComponent("rpc").appendingPathComponent(name)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(&request)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if !body.isEmpty {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        return try await send(request)
    }

    // MARK: - Insert (POST table, return=minimal)

    /// Insert one row (`[String: Any]`) or many (`[[String: Any]]`) into a table.
    func insert(_ table: String, values: Any) async throws {
        let url = SupabaseConfig.restURL.appendingPathComponent(table)
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        applyHeaders(&request)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.httpBody = try JSONSerialization.data(withJSONObject: values)
        try await sendNoContent(request)
    }

    // MARK: - Delete (DELETE table?filter)

    func delete(_ table: String, query: [URLQueryItem]) async throws {
        // Refuse an unfiltered DELETE — without a filter PostgREST would wipe the table.
        guard !query.isEmpty else { throw SupabaseRESTError.invalidURL }
        guard var components = URLComponents(
            url: SupabaseConfig.restURL.appendingPathComponent(table),
            resolvingAgainstBaseURL: false
        ) else { throw SupabaseRESTError.invalidURL }
        components.queryItems = query
        guard let url = components.url else { throw SupabaseRESTError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        applyHeaders(&request)
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        try await sendNoContent(request)
    }

    // MARK: - Shared execution

    private func sendNoContent(_ request: URLRequest) async throws {
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
    }

    private func send<T: Decodable>(_ request: URLRequest) async throws -> T {
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

    private func applyHeaders(_ request: inout URLRequest) {
        let bearer = accessToken ?? SupabaseConfig.anonKey
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(bearer)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
    }
}
