// ErrorView.swift
// MockProjectAIDD
//
// Shared error screen template for 403 Access Denied and 404 Not Found.
// Presentational only — switches visuals (illustration/title/subtitle) by kind.
// Layout values sourced from Figma [iOS] Access denied (k-7zJk2B7s) and
// [iOS] Not Found (sn2mdavs1a).
//
// Public contract:
//   ErrorView(kind: AppErrorKind, onPrimaryAction: () -> Void)

import SwiftUI

struct ErrorView: View {
    let kind: AppErrorKind
    let onPrimaryAction: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Background layer: dark base covers full screen including safe areas
            Color.errorBackground
                .ignoresSafeArea()

            // Keyvisual BG: large decorative image anchored to the right edge of the
            // screen, matching Figma bg group position (starts at x ~-636 from left =
            // right-anchored at device width). Decorative only — no hit testing.
            GeometryReader { _ in
                Image("error_keyvisual_bg")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 1215, height: 1268)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .clipped()
                    .allowsHitTesting(false)
            }
            .ignoresSafeArea()

            // Content layer — sits above backgrounds.
            // Nav bar manages its own safe-area extension; content starts below it.
            VStack(spacing: 0) {
                navigationBar
                contentSection
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Navigation Bar
    // Figma TopNavigation: total 89pt (status bar region + 42pt content row).
    // Using safeAreaInset so the dark nav background extends under the status bar
    // (matching Figma) while the back button sits in the 42pt content row below it.

    private var navigationBar: some View {
        HStack(spacing: 0) {
            Button(action: onPrimaryAction) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.errorBodyText)
                    .frame(width: 18, height: 24)
            }
            .padding(.leading, 7)

            Spacer()
        }
        .frame(height: 42)
        .padding(.top, 47)   // status bar height below the safe-area edge
        .background(
            Color.errorBackground
                .opacity(0.9)
                .ignoresSafeArea(edges: .top)
        )
    }

    // MARK: - Content Section
    // Figma mms_* frame: padding 40px top/bottom 20px h, gap 24, bg #00101A

    private var contentSection: some View {
        VStack(spacing: 24) {
            headerGroup
            illustrationImage
            divider
            primaryButton
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Header Group (title + divider + subtitle)
    // gap 8, width 335

    private var headerGroup: some View {
        VStack(spacing: 8) {
            Text(kind.title)
                .font(.custom("Montserrat", size: 18).weight(.bold))
                .foregroundStyle(Color.errorTitleGold)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .lineLimit(1)

            Rectangle()
                .fill(Color.errorDivider)
                .frame(height: 1)

            Text(kind.subtitle)
                .font(.custom("Montserrat", size: 14).weight(.medium))
                .foregroundStyle(Color.errorBodyText)
                .multilineTextAlignment(.center)
                .lineSpacing(6)   // lineHeight 20 on size 14 → ~6pt extra
                .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Illustration
    // Figma: 320×248.433, aspect 76/59

    private var illustrationImage: some View {
        Image(kind.illustrationAssetName)
            .resizable()
            .aspectRatio(76.0 / 59.0, contentMode: .fit)
            .frame(maxWidth: .infinity)
    }

    // MARK: - Divider between illustration and button

    private var divider: some View {
        Rectangle()
            .fill(Color.errorDivider)
            .frame(height: 1)
    }

    // MARK: - Primary Button
    // Figma: height 40, radius 4, bg #FFEA9E, label Montserrat Medium 14 #00101A

    private var primaryButton: some View {
        Button(action: onPrimaryAction) {
            Text("Go back to Home")
                .font(.custom("Montserrat", size: 14).weight(.medium))
                .foregroundStyle(Color.errorButtonLabel)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .background(Color.errorButtonBg)
                .cornerRadius(4)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - AppErrorKind display data

private extension AppErrorKind {
    var title: String {
        switch self {
        case .accessDenied: return "Access Denied"
        case .notFound:     return "NOT FOUND"
        }
    }

    var subtitle: String {
        switch self {
        case .accessDenied:
            return "You don't have permission to access this resource."
        case .notFound:
            return "The resource you're looking for doesn't exist\nor has been removed."
        }
    }

    var illustrationAssetName: String {
        switch self {
        case .accessDenied: return "error_access_denied_illustration"
        case .notFound:     return "error_not_found_illustration"
        }
    }
}

// MARK: - Previews

#Preview("403 Access Denied") {
    ErrorView(kind: .accessDenied, onPrimaryAction: {})
}

#Preview("404 Not Found") {
    ErrorView(kind: .notFound, onPrimaryAction: {})
}
