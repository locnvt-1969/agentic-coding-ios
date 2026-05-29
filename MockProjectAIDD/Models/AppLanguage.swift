// AppLanguage.swift
// MockProjectAIDD

import Foundation

enum AppLanguage: String, CaseIterable, Identifiable {
    case vn = "VN"
    case en = "EN"

    var id: String { rawValue }

    var displayCode: String { rawValue }

    var flagEmoji: String {
        switch self {
        case .vn: return "🇻🇳"
        case .en: return "🇬🇧"
        }
    }

    var descriptionText: String {
        switch self {
        case .vn: return "Bắt đầu hành trình của bạn cùng SAA 2025. Đăng nhập để khám phá!"
        case .en: return "Start your journey with SAA 2025. Log in to explore!"
        }
    }

    var copyrightText: String {
        switch self {
        case .vn: return "Bản quyền thuộc về Sun* © 2025"
        case .en: return "Copyright belongs to Sun* © 2025"
        }
    }
}
