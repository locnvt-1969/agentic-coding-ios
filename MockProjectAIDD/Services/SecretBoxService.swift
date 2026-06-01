// SecretBoxService.swift
// MockProjectAIDD
//
// Secret box / gift domain — wired to Supabase via raw REST.
// Boxes are auto-granted by the grant_secret_boxes_on_heart trigger (1 per 5 ❤️
// received on the user's sent kudos). Opening a box calls the open_secret_box RPC,
// which atomically picks a random NOT-yet-owned value icon, marks the box opened,
// and adds the icon to the user's collection. RLS restricts boxes to the owner.

import Foundation

enum SecretBoxError: LocalizedError {
    case openFailed(String)

    var errorDescription: String? {
        switch self {
        case .openFailed(let msg): return msg
        }
    }
}

@MainActor
final class SecretBoxService {
    static let shared = SecretBoxService()
    private init() {}

    /// One unopened box row (RLS already scopes these to the current user).
    private struct BoxRow: Decodable { let id: String }
    /// The value_icons row returned by open_secret_box (all-null when every icon is owned).
    private struct ValueIconRow: Decodable { let id: String?; let label: String? }

    /// Current secret-box state: how many unopened boxes the user has. Always reports the
    /// `.closed` (openable) state — re-entering the screen after an open resets to closed by
    /// design; the just-won reward lives only in the VM until the next navigation.
    func currentBox() async throws -> SecretBox {
        let rows = try await SupabaseRESTClient.shared.get(
            "secret_boxes",
            query: [
                URLQueryItem(name: "select", value: "id"),
                URLQueryItem(name: "state", value: "eq.closed"),
                URLQueryItem(name: "order", value: "created_at.asc")
            ],
            as: [BoxRow].self
        )
        return SecretBox(state: .closed, reward: nil, availableCount: rows.count)
    }

    /// Open the oldest unopened box. Returns the icon won as a `Gift`.
    func openBox() async throws -> Gift {
        let rows = try await SupabaseRESTClient.shared.get(
            "secret_boxes",
            query: [
                URLQueryItem(name: "select", value: "id"),
                URLQueryItem(name: "state", value: "eq.closed"),
                URLQueryItem(name: "order", value: "created_at.asc"),
                URLQueryItem(name: "limit", value: "1")
            ],
            as: [BoxRow].self
        )
        guard let boxId = rows.first?.id else {
            throw SecretBoxError.openFailed("Bạn chưa có secret box nào để mở.")
        }

        // open_secret_box returns a value_icons row. When the user already owns all 6,
        // it returns a row of NULL fields ({"id":null,"label":null,...}) — verified against
        // the running PostgREST — never a literal JSON null, so the field-nil check is the gate.
        let icon = try await SupabaseRESTClient.shared.callRPC(
            "open_secret_box", body: ["p_box_id": boxId], as: ValueIconRow.self
        )
        guard let iconId = icon.id, let label = icon.label else {
            return Gift(id: "all_collected", title: "Bạn đã sưu tập đủ 6 icon!", detail: nil)
        }
        return Gift(id: iconId, title: label, detail: nil)
    }
}
