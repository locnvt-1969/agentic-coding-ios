// AwardDetailView.swift
// MockProjectAIDD
//
// ONE template that renders all 6 award variants by switching on award.type.
// Presentational only — no service calls, no ViewModel ownership.
// Full layout sourced from Figma award detail frames:
//   keyvisual BG (award-keyvisual-bg) overlaid at top
//   AwardTopNavigationBar (chrome: logo + language + search + bell)
//   [back chevron row — pushed screens only]
//   scrollable body:
//     KudosHeroSection ("Hệ thống ghi nhận và cảm ơn" + KUDOS logo row)
//     AwardPageHeader (eyebrow + title block)
//     award-type label (functional dropdown)
//     AwardHeroSection (medallion) + AwardCriteriaSection (description + stats)
//     SunKudosSection (Phong trào ghi nhận + banner + body + Chi tiết button)

import SwiftUI

struct AwardDetailView: View {
    let award: Award
    /// Types offered by the dropdown switcher. When non-empty and `onSelectType`
    /// is set, the type label becomes an interactive dropdown.
    var availableTypes: [AwardType] = []
    var onSelectType: ((AwardType) -> Void)? = nil
    var onBack: (() -> Void)? = nil
    // Top-nav action callbacks — no-op defaults keep tab/push containers untouched.
    var onLanguage: (() -> Void)? = nil
    var onSearch: (() -> Void)? = nil
    var onNotifications: (() -> Void)? = nil
    var onKudosDetail: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Color.awardDark.ignoresSafeArea()
            keyvisualBackground

            VStack(spacing: 0) {
                // Top chrome navigation bar (logo + language + search + bell)
                AwardTopNavigationBar(
                    onLanguage: onLanguage,
                    onSearch: onSearch,
                    onNotifications: onNotifications
                )
                // Back chevron row — only shown when pushed (onBack is set)
                if onBack != nil {
                    backRow
                }

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        // KUDOS hero header (below top nav, above AwardPageHeader)
                        KudosHeroSection()
                            .padding(.bottom, 24)

                        AwardPageHeader()
                        awardTypeLabel
                        heroAndCriteria

                        // Bottom Sun* Kudos section (after criteria)
                        SunKudosSection(onDetail: onKudosDetail)
                            .padding(.top, 32)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Keyvisual background
    // Updated to use the award-specific keyvisual extracted from Figma (node 6885:10261).
    private var keyvisualBackground: some View {
        Image("award-keyvisual-bg")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: 300)
            .clipped()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    // MARK: - Back row (pushed screens only)
    private var backRow: some View {
        HStack {
            Button(action: { onBack?() }) {
                Image(systemName: "chevron.left")
                    .foregroundStyle(Color.awardGold)
                    .frame(width: 44, height: 44)
            }
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 8)
    }

    // MARK: - Award type dropdown

    /// Interactive when `onSelectType` + `availableTypes` are provided; otherwise
    /// renders as a static label (e.g. previews).
    @ViewBuilder
    private var awardTypeLabel: some View {
        if let onSelectType, !availableTypes.isEmpty {
            Menu {
                ForEach(availableTypes) { type in
                    Button {
                        onSelectType(type)
                    } label: {
                        if type == award.type {
                            Label(type.title, systemImage: "checkmark")
                        } else {
                            Text(type.title)
                        }
                    }
                }
            } label: {
                dropdownLabelContent
            }
            .padding(.bottom, 16)
        } else {
            dropdownLabelContent
                .padding(.bottom, 16)
        }
    }

    private var dropdownLabelContent: some View {
        // Figma node 6885:10287 — fixed 160×40, left-aligned, space-between, radius 4.
        HStack(spacing: 4) {
            Text(award.type.title)
                .font(.custom("Montserrat", size: 14).weight(.regular))
                .foregroundStyle(Color.awardBodyText)
                .lineLimit(1)
            Spacer(minLength: 8)
            Image(systemName: "chevron.down")
                .font(.system(size: 12))
                .foregroundStyle(Color.awardBodyText)
        }
        .padding(.horizontal, 8)
        .frame(width: 160, height: 40, alignment: .leading)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.awardBorderMuted, lineWidth: 1)
        )
        .background(Color.awardSecondaryBtnBg)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Hero + criteria

    private var heroAndCriteria: some View {
        VStack(alignment: .center, spacing: 16) {
            AwardHeroSection(type: award.type)
            AwardCriteriaSection(type: award.type)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

struct AwardDetailView_Previews: PreviewProvider {
    private static let samples: [(String, Award)] = [
        ("MVP",      Award(id: "mvp-2025",   type: .mvp,              recipientName: "Nguyen Van A", criteria: [])),
        ("Talent",   Award(id: "tt-2025-01", type: .topTalent,        recipientName: "Tran Thi B",   criteria: [])),
        ("Manager",  Award(id: "bm-2025",    type: .bestManager,      recipientName: "Le Van C",     criteria: [])),
        ("Project",  Award(id: "tp-2025-01", type: .topProject,       recipientName: nil,            criteria: [])),
        ("Leader",   Award(id: "tpl-2025-01",type: .topProjectLeader, recipientName: "Pham Thi D",   criteria: [])),
        ("Creator",  Award(id: "sc-2025",    type: .signatureCreator, recipientName: "Hoang Van E",  criteria: [])),
    ]

    static var previews: some View {
        ForEach(samples, id: \.0) { name, award in
            AwardDetailView(award: award, onBack: {})
                .previewDisplayName(name)
        }
    }
}
