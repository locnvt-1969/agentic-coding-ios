// HomeHeroSection.swift
// MockProjectAIDD
//
// mms_2 — Hero / Main Content section
// ROOT FURTHER logo, Coming soon label (hidden when event date passed),
// countdown digits (replaced by "Sự kiện đã kết thúc" after event date),
// event info, livestream note, ABOUT AWARD + ABOUT KUDOS buttons.

import SwiftUI

struct HomeHeroSection: View {

    // MARK: - Props
    let countdown: CountdownValue
    let onAboutAwardTap: () -> Void
    let onAboutKudosTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // mms_2.1 — ROOT FURTHER logo
            Image("logo-rootfuther")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: 260, alignment: .leading)
                .padding(.bottom, 16)

            // Coming soon label — hidden once event has ended.
            // Figma: Montserrat 14 / weight 300 / lineHeight 20 / tracking 0.25 / white.
            if countdown.comingSoonVisible {
                Text("Coming soon")
                    .font(.system(size: 14, weight: .light))
                    .tracking(0.25)
                    .foregroundStyle(.white)
                    .padding(.bottom, 8)
            }

            // Countdown or event-ended state
            if countdown.eventEnded {
                Text("Sự kiện đã kết thúc")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.85))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 20)
            } else {
                HeroCountdownRow(countdown: countdown)
                    .padding(.bottom, 20)
            }

            // Event info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text("Thời gian:")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.75))
                    Text("26/12/2025")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }

                HStack(spacing: 4) {
                    Text("Địa điểm:")
                        .font(.system(size: 14, weight: .regular))
                        .foregroundStyle(Color.white.opacity(0.75))
                    Text("Âu Cơ Art Center")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                }

                Text("Tường thuật trực tiếp tại Group Facebook Sun* Family")
                    .font(.system(size: 13, weight: .regular))
                    .foregroundStyle(Color.white.opacity(0.75))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.bottom, 20)

            // mms_2.2 (primary) + mms_2.3 (secondary) — CTA buttons
            HStack(spacing: 12) {
                HeroCTAButton(title: "ABOUT AWARD", style: .primary, action: onAboutAwardTap)
                HeroCTAButton(title: "ABOUT KUDOS", style: .secondary, action: onAboutKudosTap)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
}

// MARK: - Countdown Row
// Figma frame 6885:8988: HStack with 16pt gap between units, vertically center-aligned.

private struct HeroCountdownRow: View {
    let countdown: CountdownValue

    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            CountdownUnit(value: countdown.days, label: "DAYS")
            CountdownUnit(value: countdown.hours, label: "HOURS")
            CountdownUnit(value: countdown.minutes, label: "MINUTES")
        }
    }
}

// MARK: - Single countdown unit (digit pair + label)
// Figma frame 6885:8989: VStack gap 4, digit pair (HStack gap 8) + 18pt label left-aligned.

private struct CountdownUnit: View {
    let value: Int
    let label: String

    private var tens: Int { (value / 10) % 10 }
    private var ones: Int { value % 10 }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                CountdownDigit(digit: tens)
                CountdownDigit(digit: ones)
            }
            // Figma: Montserrat 18 / weight 400 / lineHeight 24 / tracking 0.5 / white.
            Text(label)
                .font(.system(size: 18, weight: .regular))
                .tracking(0.5)
                .foregroundStyle(.white)
        }
    }
}

// MARK: - Single digit tile
// Figma rect 6885:8992: 32x56, radius 8, border 0.5pt cream #FFEA9E,
// background gradient white 100% → 10%, tile-level opacity 0.5, backdrop-blur ~16pt.
// Digit text uses a "Digital Numbers" font in Figma — approximated here with the
// system monospaced face (closest stock match, prevents shipping a custom .ttf).

private struct CountdownDigit: View {
    let digit: Int

    var body: some View {
        Text("\(digit)")
            .font(.system(size: 32, weight: .regular, design: .monospaced))
            .foregroundStyle(.white)
            .frame(width: 32, height: 56)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(1.0),
                                Color.white.opacity(0.10)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .opacity(0.5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .strokeBorder(Color(hex: "#FFEA9E").opacity(0.5), lineWidth: 0.5)
                    )
            )
    }
}

// MARK: - CTA Button

/// Two Home CTA styles from Figma:
/// - .primary   = solid cream `#FFEA9E` background, navy `#00101A` text (mms_2.2, mms_5.3)
/// - .secondary = cream 10% bg, gold `#998C5F` border, white text (mms_2.3)
enum HomeCTAStyle {
    case primary
    case secondary
}

struct HomeCTAButton: View {
    let title: String
    let style: HomeCTAStyle
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(textColor)
                    .tracking(0.5)
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(textColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background(backgroundLayer)
        }
        .buttonStyle(.plain)
    }

    private var textColor: Color {
        switch style {
        case .primary:   return Color(hex: "#00101A")
        case .secondary: return .white
        }
    }

    @ViewBuilder
    private var backgroundLayer: some View {
        switch style {
        case .primary:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#FFEA9E"))
        case .secondary:
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: "#FFEA9E").opacity(0.10))
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(Color(hex: "#998C5F"), lineWidth: 1)
                )
        }
    }
}

/// Convenience alias retained for HomeHeroSection's local call sites.
private typealias HeroCTAButton = HomeCTAButton

// MARK: - Preview

#Preview("Counting down") {
    HomeHeroSection(
        countdown: .placeholder,
        onAboutAwardTap: {},
        onAboutKudosTap: {}
    )
    .background(Color(hex: "#040D14"))
}

#Preview("Event ended") {
    HomeHeroSection(
        countdown: CountdownValue(days: 0, hours: 0, minutes: 0,
                                  comingSoonVisible: false, eventEnded: true),
        onAboutAwardTap: {},
        onAboutKudosTap: {}
    )
    .background(Color(hex: "#040D14"))
}
