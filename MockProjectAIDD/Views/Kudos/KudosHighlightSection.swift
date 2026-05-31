// KudosHighlightSection.swift
// MockProjectAIDD
//
// Highlight Kudos carousel section for KudosBoardView.
// Presentational only: no service calls.
//
// Filter dropdown ownership:
//   Each FilterOverlay is anchored via GeometryReader on its trigger button so the
//   dropdown appears directly beneath the tapped button — independent of scroll offset.
//   Hashtag filter ← left button (x≈20), Phòng-ban filter ← right button (x≈157).
//   The dim backdrop is placed as a full-screen overlay on the outer ZStack in
//   KudosBoardView (passed via onShowHashtag/onShowDepartment callbacks), but the
//   dropdown card itself is owned here via .overlay(alignment:) on the filter-button row.

import SwiftUI

// MARK: - KudosHighlightSection

struct KudosHighlightSection: View {
    let kudos: [Kudo]
    @Binding var currentPage: Int

    // Filter state (owned by parent KudosBoardView, mirrored here for display)
    let selectedHashtag: Hashtag?
    let selectedDepartment: Department?

    // Filter data (needed to render dropdown lists)
    let hashtags: [Hashtag]
    let departments: [Department]

    // Selection callbacks → bubble up to parent
    let onSelectHashtag: (Hashtag?) -> Void
    let onSelectDepartment: (Department?) -> Void

    let onOpenKudo: (Kudo) -> Void

    // MARK: Local dropdown visibility
    @State private var showHashtagDropdown = false
    @State private var showDepartmentDropdown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            KudosSectionHeader(title: "HIGHLIGHT KUDOS", subtitle: "Sun* Annual Awards 2025")

            // zIndex keeps the open dropdown above the carousel below it.
            filterRow
                .zIndex(1)

            if kudos.isEmpty {
                KudosEmptyState(message: "Chưa có kudos nổi bật")
                    .padding(.horizontal, 20)
            } else {
                carouselContent
            }
        }
    }

    // MARK: - Filter button row with inline dropdowns

    private var filterRow: some View {
        HStack(spacing: 8) {
            // Left: Hashtag filter button
            KudosFilterButton(
                label: selectedHashtag.map(\.name) ?? "Hashtag",
                onTap: {
                    showDepartmentDropdown = false
                    showHashtagDropdown.toggle()
                }
            )
            .frame(width: 129)
            .overlay(alignment: .topLeading) {
                if showHashtagDropdown {
                    FilterOverlay(
                        items: hashtags,
                        selectedID: selectedHashtag?.id,
                        labelKeyPath: \.name,
                        onSelect: { tag in
                            onSelectHashtag(tag)
                            showHashtagDropdown = false
                        },
                        onDismiss: { showHashtagDropdown = false }
                    )
                    .offset(y: 44) // appear just below the 40pt button + 4pt gap
                    .transition(.opacity)
                    .zIndex(10)
                }
            }

            // Right: Phòng-ban filter button
            KudosFilterButton(
                label: selectedDepartment.map(\.name) ?? "Phòng ban",
                onTap: {
                    showHashtagDropdown = false
                    showDepartmentDropdown.toggle()
                }
            )
            .frame(width: 129)
            .overlay(alignment: .topLeading) {
                if showDepartmentDropdown {
                    FilterOverlay(
                        items: departments,
                        selectedID: selectedDepartment?.id,
                        labelKeyPath: \.name,
                        onSelect: { dept in
                            onSelectDepartment(dept)
                            showDepartmentDropdown = false
                        },
                        onDismiss: { showDepartmentDropdown = false }
                    )
                    .offset(y: 44)
                    .transition(.opacity)
                    .zIndex(10)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.2), value: showHashtagDropdown)
        .animation(.easeInOut(duration: 0.2), value: showDepartmentDropdown)
    }

    // MARK: - Carousel

    private var carouselContent: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(kudos.enumerated()), id: \.element.id) { index, kudo in
                    KudoCard(
                        kudo: kudo,
                        onCopyLink: {},
                        onViewDetail: { k in onOpenKudo(k) }
                    )
                    .padding(.horizontal, 20)
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 280)

            HStack(spacing: 8) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.kudosAccent)

                Text("\(currentPage + 1)/\(kudos.count)")
                    .font(.custom("Montserrat", size: 12))
                    .foregroundStyle(Color.white)

                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
                    .foregroundStyle(Color.kudosAccent)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview("KudosHighlightSection") {
    let kudos: [Kudo] = [
        Kudo(
            id: "k1",
            sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
            recipients: [User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")],
            message: "Cảm ơn người em bình thường nhưng phi thường :D",
            hashtags: [Hashtag(id: "h1", name: "#Dedicated", group: nil)],
            isAnonymous: false,
            createdAt: Date(),
            reactionCount: 1000,
            isHighlighted: true
        )
    ]
    KudosHighlightSection(
        kudos: kudos,
        currentPage: .constant(0),
        selectedHashtag: nil,
        selectedDepartment: nil,
        hashtags: [Hashtag(id: "h1", name: "#Dedicated", group: nil)],
        departments: [Department(id: "d1", name: "CEVC2")],
        onSelectHashtag: { _ in },
        onSelectDepartment: { _ in },
        onOpenKudo: { _ in }
    )
    .background(Color(hex: "00101A"))
}
