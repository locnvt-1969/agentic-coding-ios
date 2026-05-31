// Color+SecretBoxTokens.swift
// MockProjectAIDD
//
// SecretBox screen color tokens — sourced from Figma Open secret box frames.
// Do NOT redefine Color(hex:) — that lives in Color+Hex.swift.

import SwiftUI

extension Color {
    /// Background base (#00101A)
    static let secretBoxDark        = Color(hex: "00101A")
    /// Gold accent for title and count (#FFEA9E)
    static let secretBoxGold        = Color(hex: "FFEA9E")
    /// Divider line (#2E3940)
    static let secretBoxDivider     = Color(hex: "2E3940")
    /// Body white text
    static let secretBoxBodyText    = Color.white
    /// Standby reward text (#FFEA9E same gold)
    static let secretBoxRewardText  = Color(hex: "FFEA9E")
    /// Reward item glow tint (#FFF3C5)
    static let secretBoxRewardGlow  = Color(hex: "FFF3C5")
}
