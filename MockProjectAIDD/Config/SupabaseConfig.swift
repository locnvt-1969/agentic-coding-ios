// SupabaseConfig.swift
// MockProjectAIDD
//
// Local Supabase instance configuration. Replace `anonKey` with the value
// printed by `supabase status` if/when the project is bound to a real backend.

import Foundation

enum SupabaseConfig {
    /// Local Supabase REST API base URL. Constructed from URLComponents to avoid force-unwrap.
    static let baseURL: URL = {
        var c = URLComponents()
        c.scheme = "http"
        c.host = "localhost"
        c.port = 54321
        // Fallback to about:blank — AwardsService will surface .network error if this path fires.
        return c.url ?? URL(string: "about:blank") ?? URL(fileURLWithPath: "/")
    }()

    /// Anon API key for the local instance.
    /// Default Supabase CLI anon key for local dev — safe to commit.
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0"

    static var restURL: URL { baseURL.appendingPathComponent("rest/v1") }

    /// GoTrue auth API base (`/auth/v1`).
    static var authURL: URL { baseURL.appendingPathComponent("auth/v1") }
}
