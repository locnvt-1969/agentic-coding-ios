// AwardType.swift
// MockProjectAIDD
//
// The 6 award variants. Visual values (icon asset names, hex colors, copy)
// are placeholders here and refined against each MoMorph award frame in Track A (phase-10).

import Foundation

enum AwardType: String, CaseIterable, Identifiable, Hashable, Codable {
    case bestManager
    case mvp
    case signatureCreator
    case topProject
    case topProjectLeader
    case topTalent

    var id: String { rawValue }

    /// Maps a backend award `id` (from the awards table, e.g. "top-talent") to an AwardType.
    /// The DB uses "top-manager" which has no exact case here → falls back to `.bestManager`.
    /// Unknown ids fall back to `.topTalent`.
    init(awardId: String) {
        switch awardId {
        case "top-talent":  self = .topTalent
        case "top-project": self = .topProject
        case "top-manager": self = .bestManager
        default:            self = .topTalent
        }
    }

    /// Display title — confirm against Figma copy during Track A.
    var title: String {
        switch self {
        case .bestManager: return "Best Manager"
        case .mvp: return "MVP"
        case .signatureCreator: return "Signature 2025 - Creator"
        case .topProject: return "Top Project"
        case .topProjectLeader: return "Top Project Leader"
        case .topTalent: return "Top Talent"
        }
    }

    /// Asset namespace under Assets.xcassets/Momorph/Awards/<folder>/.
    var assetFolder: String {
        switch self {
        case .bestManager: return "BestManager"
        case .mvp: return "MVP"
        case .signatureCreator: return "SignatureCreator"
        case .topProject: return "TopProject"
        case .topProjectLeader: return "TopProjectLeader"
        case .topTalent: return "TopTalent"
        }
    }

    /// Full medallion graphic (ring + pedestal + wordmark as one image).
    /// Named <Folder>_medallion in Assets.xcassets/Momorph/Awards/.
    var medallionAsset: String {
        "\(assetFolder)_medallion"
    }
}
