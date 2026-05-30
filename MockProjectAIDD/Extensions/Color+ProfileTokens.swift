// Color+ProfileTokens.swift
// MockProjectAIDD
//
// Profile screen color tokens. Do NOT redefine Color(hex:) — lives in Color+Hex.swift.
// Do NOT redefine kudos* tokens — lives in Color+KudosTokens.swift.

import SwiftUI

extension Color {
    // Profile header / hero area
    static let profileNameHighlight  = Color(hex: "FFEA9E")  // #FFEA9E — name text
    static let profileTextPrimary    = Color.white            // white body text
    static let profileTextSecondary  = Color(hex: "999999")   // muted text (dept, date)
    static let profileDark           = Color(hex: "00101A")   // deepest bg
    static let profileContainer      = Color(hex: "00070C")   // stats card bg
    static let profileBorderMuted    = Color(hex: "998C5F")   // border on stats card
    static let profileDivider        = Color(hex: "2E3940")   // divider inside stats card
    static let profileButtonBg       = Color(hex: "FFEA9E")   // "Mở Secret Box" button bg
    static let profileButtonText     = Color(hex: "00101A")   // button label
    // Badge / huy hiệu
    static let profileBadgeBg        = Color(hex: "323231")   // empty badge slot
    static let profileBadgeBorder    = Color.white
    // Dropdown
    static let profileDropdownBg     = Color(hex: "FFEA9E").opacity(0.10)
    static let profileDropdownBorder = Color(hex: "998C5F")
    static let profileDropdownActive = Color(hex: "FFEA9E").opacity(0.10)
}
