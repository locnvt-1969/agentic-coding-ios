// ProfileKudosSection.swift
// MockProjectAIDD
//
// Kudos section on the Profile screen: "Sun* Annual Awards 2025 / KUDOS" header,
// dropdown filter (Đã gửi / Đã nhận), and the list of KudoCards.
// Presentational only — data + callbacks as props.
// Design: mms_4_header + mms_dropdown + mms_A_Dropdown-List + mms_5_kudos list

import SwiftUI

// MARK: - KudosFilterOption

enum KudosFilterOption: String, CaseIterable {
    case received = "Đã nhận"
    case sent     = "Đã gửi"

    func label(count: Int) -> String { "\(rawValue) (\(count))" }
}

// MARK: - ProfileKudosSection

struct ProfileKudosSection: View {
    let kudos: [Kudo]
    let receivedCount: Int
    let sentCount: Int
    @Binding var selectedFilter: KudosFilterOption
    /// When true the filter is rendered as static text (no chevron, not tappable).
    /// Pass `true` from ProfileOtherView to lock the dropdown to .received.
    var isFilterLocked: Bool = false
    var onCopyLink: ((Kudo) -> Void)? = nil
    var onViewDetail: ((Kudo) -> Void)? = nil

    @State private var showDropdown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionHeader
                .padding(.bottom, 8)
            filterDropdown
                .padding(.bottom, 24)
            kudosList
        }
    }

    // MARK: Section header

    private var sectionHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Sun* Annual Awards 2025")
                .font(.custom("Montserrat-Regular", size: 12))
                .foregroundStyle(Color.white)
            Rectangle()
                .fill(Color.profileDivider)
                .frame(height: 1)
            Text("KUDOS")
                .font(.custom("Montserrat-Medium", size: 22))
                .foregroundStyle(Color.profileNameHighlight)
        }
    }

    // MARK: Dropdown filter

    private func filterLabel(for option: KudosFilterOption) -> String {
        option.label(count: option == .received ? receivedCount : sentCount)
    }

    private var filterDropdown: some View {
        ZStack(alignment: .topLeading) {
            if isFilterLocked {
                // Locked (other-user profile): static "Đã nhận N kudos" label per design
                Text("Đã nhận \(receivedCount) kudos")
                    .font(.custom("Montserrat-Regular", size: 14))
                    .foregroundStyle(Color.white)
                    .tracking(0.25)
                    .padding(.horizontal, 8)
                    .frame(height: 40)
                    .background(Color.profileDropdownBg)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.profileDropdownBorder, lineWidth: 1))
            } else {
                // Interactive trigger button
                Button(action: { showDropdown.toggle() }) {
                    HStack(spacing: 8) {
                        Text(filterLabel(for: selectedFilter))
                            .font(.custom("Montserrat-Regular", size: 14))
                            .foregroundStyle(Color.white)
                            .tracking(0.25)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.white)
                    }
                    .padding(.horizontal, 8)
                    .frame(height: 40)
                    .background(Color.profileDropdownBg)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.profileDropdownBorder, lineWidth: 1))
                }
                .buttonStyle(.plain)
                if showDropdown {
                    dropdownMenu.offset(y: 44).zIndex(10)
                }
            }
        }
    }

    private var dropdownMenu: some View {
        VStack(spacing: 0) {
            ForEach(KudosFilterOption.allCases, id: \.self) { option in
                Button(action: {
                    selectedFilter = option
                    showDropdown = false
                }) {
                    HStack {
                        Text(filterLabel(for: option))
                        .font(.custom("Montserrat-Medium", size: 14))
                        .foregroundStyle(
                            selectedFilter == option ? Color.profileNameHighlight : Color.white
                        )
                        .tracking(0.1)
                        Spacer()
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 40)
                    .background(
                        selectedFilter == option
                            ? Color.profileDropdownActive
                            : Color.clear
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(Color.profileContainer)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.profileDropdownBorder, lineWidth: 1)
        )
        .frame(width: 118)
    }

    // MARK: Kudos list

    private var kudosList: some View {
        VStack(spacing: 24) {
            ForEach(kudos) { kudo in
                KudoCard(
                    kudo: kudo,
                    onCopyLink: onCopyLink.map { cb in { cb(kudo) } },
                    onViewDetail: onViewDetail
                )
            }
        }
    }
}

// MARK: - Preview

#Preview("ProfileKudosSection") {
    @Previewable @State var filter: KudosFilterOption = .sent

    let sampleKudo = Kudo(
        id: "k1",
        sender: User(id: "u1", name: "Huỳnh Dương Xuân", departmentName: "CEVC10"),
        recipients: [User(id: "u2", name: "Dương Xuân Huỳnh", departmentName: "CEVC10")],
        message: "Cảm ơn người em bình thường nhưng phi thường :D Cảm ơn sự chăm chỉ, cần mẫn của em đã tạo động lực rất...",
        hashtags: [
            Hashtag(id: "h1", name: "#Dedicated", group: nil),
            Hashtag(id: "h2", name: "#Inspring", group: nil)
        ],
        isAnonymous: false,
        createdAt: ISO8601DateFormatter().date(from: "2025-10-30T10:00:00Z") ?? Date(),
        reactionCount: 1000,
        isHighlighted: true
    )

    ScrollView {
        ProfileKudosSection(
            kudos: [sampleKudo, sampleKudo, sampleKudo],
            receivedCount: 5,
            sentCount: 5,
            selectedFilter: $filter,
            onCopyLink: { _ in },
            onViewDetail: { _ in }
        )
        .padding(.horizontal, 20)
    }
    .background(Color.profileDark)
}
