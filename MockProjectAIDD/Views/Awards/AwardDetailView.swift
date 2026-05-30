// AwardDetailView.swift
// MockProjectAIDD
//
// ONE template that renders all 6 award variants by switching on award.type.
// Presentational only — no service calls, no ViewModel ownership.
// Layout sourced from Figma award detail frames (phase-10):
//   keyvisual BG → nav bar → scrollable body:
//     AwardPageHeader (eyebrow + title block)
//     award-type label (dropdown placeholder)
//     hero medallion → criteria section

import SwiftUI

struct AwardDetailView: View {
    let award: Award
    var onBack: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .top) {
            Color.awardDark.ignoresSafeArea()
            keyvisualBackground

            VStack(spacing: 0) {
                navBar
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        AwardPageHeader()
                        awardTypeLabel
                        heroAndCriteria
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
    }

    // MARK: - Keyvisual background

    private var keyvisualBackground: some View {
        Image("profile_keyvisual_bg")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(maxWidth: .infinity, maxHeight: 240)
            .clipped()
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .ignoresSafeArea()
            .allowsHitTesting(false)
    }

    // MARK: - Nav bar

    private var navBar: some View {
        HStack {
            if onBack != nil {
                Button(action: { onBack?() }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(Color.awardGold)
                        .frame(width: 44, height: 44)
                }
            }
            Spacer()
        }
        .frame(height: 44)
        .padding(.horizontal, 8)
    }

    // MARK: - Award type label (dropdown placeholder — presentational)

    private var awardTypeLabel: some View {
        HStack(spacing: 4) {
            Text(award.type.title)
                .font(.custom("Montserrat", size: 14).weight(.regular))
                .foregroundStyle(Color.awardBodyText)
            Image(systemName: "chevron.down")
                .font(.system(size: 12))
                .foregroundStyle(Color.awardBodyText)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.awardBorderMuted, lineWidth: 1)
        )
        .background(Color.awardSecondaryBtnBg)
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.bottom, 16)
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
