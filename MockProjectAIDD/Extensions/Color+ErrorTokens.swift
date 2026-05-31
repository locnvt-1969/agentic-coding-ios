// Color+ErrorTokens.swift
// MockProjectAIDD
//
// Error screen color tokens — sourced from Figma [iOS] Access denied + Not Found frames.
// Do NOT redefine Color(hex:) — that lives in Color+Hex.swift.

import SwiftUI

extension Color {
    /// Background base (#00101A) — same dark as secretBox but owned by error screens
    static let errorBackground   = Color(hex: "00101A")
    /// Gold accent for error code title (#FFEA9E)
    static let errorTitleGold    = Color(hex: "FFEA9E")
    /// Divider line (#2E3940)
    static let errorDivider      = Color(hex: "2E3940")
    /// Body text (white)
    static let errorBodyText     = Color.white
    /// Primary button background (#FFEA9E)
    static let errorButtonBg     = Color(hex: "FFEA9E")
    /// Primary button label (#00101A)
    static let errorButtonLabel  = Color(hex: "00101A")
}
