// LanguageDropdownView.swift — Login screen language picker (mms_A_Dropdown-List)
// MoMorph: screenId uUvW6Qm1ve | Default: VN | Options: VN (🇻🇳), EN (🇬🇧)
// Collapsed: flag + code + chevron pill. Expanded: floating overlay list.
// Selected row: white/0.18 bg. Pressed row: white/0.10 bg.

import SwiftUI

// MARK: - Model

struct LanguageOption: Identifiable, Equatable {
    let id: String    // language code ("VN" / "EN")
    let flag: String  // emoji flag
    let code: String  // display label

    static let vn = LanguageOption(id: "VN", flag: "🇻🇳", code: "VN")
    static let en = LanguageOption(id: "EN", flag: "🇬🇧", code: "EN")
    static let all: [LanguageOption] = [.vn, .en]
}

// MARK: - LanguageDropdownView

/// Presentational language picker. Floats as an overlay — does not push layout content.
struct LanguageDropdownView: View {

    let selectedLanguage: String
    let onLanguageChange: (String) -> Void
    var supportedLanguages: [String] = ["VN", "EN"]

    @State private var isExpanded = false

    private var options: [LanguageOption] {
        supportedLanguages.compactMap { code in LanguageOption.all.first { $0.id == code } }
    }

    private var current: LanguageOption {
        options.first { $0.id == selectedLanguage } ?? .vn
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            collapsedButton
            if isExpanded {
                expandedList.offset(y: 40)
            }
        }
        .background(
            Group {
                if isExpanded {
                    Color.clear
                        .contentShape(Rectangle())
                        .ignoresSafeArea()
                        .onTapGesture { isExpanded = false }
                }
            }
        )
    }

    // MARK: Collapsed pill

    private var collapsedButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
        } label: {
            HStack(spacing: 4) {
                Text(current.flag).font(.system(size: 18))
                Text(current.code)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.2)))
        }
        .buttonStyle(.plain)
    }

    // MARK: Expanded overlay list

    private var expandedList: some View {
        VStack(spacing: 0) {
            ForEach(options) { option in optionRow(option) }
        }
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(white: 0.12))
                .shadow(color: .black.opacity(0.35), radius: 12, x: 0, y: 6)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .frame(width: 100)
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    // MARK: Option row

    @ViewBuilder
    private func optionRow(_ option: LanguageOption) -> some View {
        let isSelected = option.id == selectedLanguage
        Button {
            withAnimation(.easeInOut(duration: 0.15)) { isExpanded = false }
            if option.id != selectedLanguage { onLanguageChange(option.id) }
        } label: {
            HStack(spacing: 8) {
                Text(option.flag).font(.system(size: 18))
                Text(option.code)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? Color.white.opacity(0.18) : Color.clear)
        }
        .buttonStyle(LanguageOptionButtonStyle())
    }
}

// MARK: - Button style (pressed highlight)

private struct LanguageOptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.1) : Color.clear)
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        LinearGradient(
            colors: [Color(red: 0.05, green: 0.15, blue: 0.35),
                     Color(red: 0.02, green: 0.08, blue: 0.20)],
            startPoint: .top, endPoint: .bottom
        )
        .ignoresSafeArea()

        VStack {
            HStack {
                Spacer()
                LanguageDropdownView(
                    selectedLanguage: "VN",
                    onLanguageChange: { print("Language: \($0)") }
                )
                .padding(.trailing, 20)
            }
            .padding(.top, 60)
            Spacer()
        }
    }
}
