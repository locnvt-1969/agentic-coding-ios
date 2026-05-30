// Color+AwardTokens.swift
// MockProjectAIDD
//
// Award screen color tokens — sourced from Figma Award detail frames.
// Do NOT redefine Color(hex:) — that lives in Color+Hex.swift.

import SwiftUI

extension Color {
    /// Primary gold accent used for award title text, borders, glow (#FFEA9E)
    static let awardGold        = Color(hex: "FFEA9E")
    /// Dark base background used across all award screens (#00101A → dark navy)
    static let awardDark        = Color(hex: "00101A")
    /// Divider line color (#2E3940)
    static let awardDivider     = Color(hex: "2E3940")
    /// Body text (white)
    static let awardBodyText    = Color.white
    /// Award border muted (#998C5F)
    static let awardBorderMuted = Color(hex: "998C5F")
    /// Dropdown / secondary button background (rgba(255, 234, 158, 0.10))
    static let awardSecondaryBtnBg = Color(hex: "FFEA9E").opacity(0.1)
    /// Hero medallion fallback background (#1A2A35)
    static let awardHeroBg  = Color(hex: "1A2A35")
    /// Hero medallion glow colour (#FAE287)
    static let awardHeroGlow = Color(hex: "FAE287")
}
