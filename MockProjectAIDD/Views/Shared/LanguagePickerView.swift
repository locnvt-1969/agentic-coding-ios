// LanguagePickerView.swift — Standalone language picker (phase-06)
// MoMorph: screenId uUvW6Qm1ve | Bridges AppLanguage ↔ LanguageDropdownView
//
// Design notes (from Figma uUvW6Qm1ve):
//   - Container: bg #00070C, border 1px #998C5F, border-radius 8px, padding 6px
//   - Selected row bg: rgba(255,234,158,0.20) — warm gold tint
//   - Row text: Montserrat 14pt/500, white
//   - Row height ~40px, inner padding 16px, flag 24x24, gap 4px
//   - Collapsed pill: 90x32, padding 4 0 4 8, radius 4, gap 8
//
// The existing LanguageDropdownView (Login-owned) closely approximates the design.
// This wrapper exposes the AppLanguage-typed public contract for reuse across the app
// without modifying or duplicating the Login-owned component.

import SwiftUI

// MARK: - LanguagePickerView

/// Thin wrapper around LanguageDropdownView that exposes an AppLanguage-typed contract.
/// Presentational only — no persistence or service calls.
/// Locale persistence is handled in phase-19.
struct LanguagePickerView: View {

    let selected: AppLanguage
    let onSelect: (AppLanguage) -> Void

    var body: some View {
        LanguageDropdownView(
            selectedLanguage: selected.rawValue,
            onLanguageChange: { code in
                let language = AppLanguage(rawValue: code) ?? .vn
                onSelect(language)
            }
        )
    }
}

// MARK: - Preview

#Preview("VN selected") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.15, blue: 0.35),
                Color(red: 0.02, green: 0.08, blue: 0.20)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            HStack {
                Spacer()
                LanguagePickerView(selected: .vn) { lang in
                    print("Selected: \(lang.rawValue)")
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 60)
            Spacer()
        }
    }
}

#Preview("EN selected") {
    ZStack {
        LinearGradient(
            colors: [
                Color(red: 0.05, green: 0.15, blue: 0.35),
                Color(red: 0.02, green: 0.08, blue: 0.20)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            HStack {
                Spacer()
                LanguagePickerView(selected: .en) { lang in
                    print("Selected: \(lang.rawValue)")
                }
                .padding(.trailing, 20)
            }
            .padding(.top, 60)
            Spacer()
        }
    }
}
