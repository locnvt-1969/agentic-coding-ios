// AwardsService.swift
// MockProjectAIDD
//
// Fetches award records from the local Supabase REST API.
// Decodes AwardDTO JSON → AwardItem domain model.

import Foundation

// MARK: - Error

enum AwardsError: LocalizedError {
    case network(String)
    case decoding
    case serverStatus(Int)

    var errorDescription: String? {
        switch self {
        case .network(let msg):    return "Lỗi mạng: \(msg)"
        case .decoding:            return "Không thể đọc dữ liệu giải thưởng."
        case .serverStatus(let c): return "Máy chủ trả về lỗi \(c)."
        }
    }
}

// MARK: - DTO

private struct AwardDTO: Decodable {
    let id: String
    let name: String
    let description: String
    let thumbnail_name: String
    let display_order: Int
}

// MARK: - Service

@MainActor
final class AwardsService {
    static let shared = AwardsService()
    private init() {}

    private let session = URLSession.shared

    func fetchAwards() async throws -> [AwardItem] {
        guard var components = URLComponents(
            url: SupabaseConfig.restURL.appendingPathComponent("awards"),
            resolvingAgainstBaseURL: false
        ) else {
            throw AwardsError.network("Invalid base URL")
        }
        components.queryItems = [
            URLQueryItem(name: "select", value: "*"),
            URLQueryItem(name: "order", value: "display_order.asc")
        ]

        guard let url = components.url else {
            throw AwardsError.network("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw AwardsError.network(error.localizedDescription)
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw AwardsError.serverStatus(http.statusCode)
        }

        let dtos: [AwardDTO]
        do {
            dtos = try JSONDecoder().decode([AwardDTO].self, from: data)
        } catch {
            throw AwardsError.decoding
        }

        return dtos.map { dto in
            AwardItem(
                id: dto.id,
                thumbnailName: dto.thumbnail_name,
                name: dto.name,
                description: dto.description
            )
        }
    }
}
