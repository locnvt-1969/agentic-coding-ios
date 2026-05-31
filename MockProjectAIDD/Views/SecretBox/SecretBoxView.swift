// SecretBoxView.swift
// MockProjectAIDD
//
// Root container for all 3 secret-box states: closed → opening → standby.
// Presentational only — state is passed in as a prop; onOpen signals
// the tap so the parent (SecretBoxViewModel, phase-19) can advance state.
//
// Contract: SecretBoxView(state: SecretBox.State, reward: Gift?, onOpen: () -> Void)
//
// Visual structure (all 3 states share the same chrome):
//   ZStack
//   ├── keyvisual background (full-bleed)
//   ├── TopNavigation bar (semi-opaque dark)
//   └── content card (dark rounded container, y:89 → 812)
//       └── state-specific subview with .transition + .animation

import SwiftUI

struct SecretBoxView: View {
    let state: SecretBox.State
    let reward: Gift?
    let onOpen: () -> Void

    // Sample box count — presentational; real count injected by parent
    var boxCount: Int = 5

    var body: some View {
        ZStack(alignment: .top) {
            Color.secretBoxDark.ignoresSafeArea()
            keyvisualBackground
            contentCard
            topNavigation
        }
        .navigationBarHidden(true)
    }

    // MARK: - Keyvisual background

    private var keyvisualBackground: some View {
        Group {
            if state == .standby {
                Image("secretbox_standby_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image("secretbox_keyvisual_bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .ignoresSafeArea()
        .allowsHitTesting(false)
    }

    // MARK: - Top navigation bar
    // Figma: width 375, height 89, bg #00101A opacity 0.9
    // Title: "Secret Box" Helvetica Neue 17pt Medium white centred

    private var topNavigation: some View {
        VStack(spacing: 0) {
            // Status bar placeholder
            Color.clear.frame(height: 47)

            // Nav content row
            HStack(spacing: 0) {
                // Back chevron area (Figma: 130×42, padding 7px left)
                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Color.secretBoxBodyText)
                        .frame(width: 24, height: 24)
                }
                .frame(width: 130, height: 42, alignment: .leading)
                .padding(.leading, 7)

                // Centred title
                Text("Secret Box")
                    .font(Font(UIFont(name: "HelveticaNeue-Medium", size: 17) ?? .systemFont(ofSize: 17, weight: .medium)))
                    .foregroundStyle(Color.secretBoxBodyText)
                    .frame(width: 115, height: 42)

                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 89)
        .background(Color.secretBoxDark.opacity(0.9))
    }

    // MARK: - Content card
    // Figma: y:89, h:723, bg #00101A, cornerRadius 7.304px, padding 13.694/7.304

    private var contentCard: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 89) // clears nav bar

            ZStack {
                RoundedRectangle(cornerRadius: 7.304)
                    .fill(Color.secretBoxDark)

                stateContent
                    .padding(.horizontal, 7.304)
                    .padding(.vertical, 13.694)
            }
            .animation(.easeInOut(duration: 0.35), value: state)
            .frame(height: 723)
        }
    }

    // MARK: - Animated state content

    @ViewBuilder
    private var stateContent: some View {
        switch state {
        case .closed:
            SecretBoxClosedView(boxCount: boxCount, onOpen: onOpen)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.97)),
                    removal: .opacity.combined(with: .scale(scale: 1.03))
                ))
        case .opening:
            SecretBoxOpeningView(boxCount: boxCount)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 1.03)),
                    removal: .opacity
                ))
        case .standby:
            SecretBoxStandbyView(reward: reward)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .bottom)),
                    removal: .opacity
                ))
        }
    }
}

// MARK: - Previews

#Preview("Closed") {
    SecretBoxView(state: .closed, reward: nil, onOpen: {})
        .frame(width: 375, height: 812)
}

#Preview("Opening") {
    SecretBoxView(state: .opening, reward: nil, onOpen: {})
        .frame(width: 375, height: 812)
}

#Preview("Standby — with reward") {
    SecretBoxView(
        state: .standby,
        reward: Gift(id: "g1", title: "Khăn Root Further", detail: nil),
        onOpen: {}
    )
    .frame(width: 375, height: 812)
}
