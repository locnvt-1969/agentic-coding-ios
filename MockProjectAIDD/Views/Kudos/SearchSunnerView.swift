// SearchSunnerView.swift
// MockProjectAIDD
//
// Presentational Search Sunner screen — three states: idle (recent list),
// searching/loading (spinner in search bar), results list.
// Design source:
//   Idle:      MoMorph [iOS] Sun*Kudos_Search Sunner  (3jgwke3E8O)
//   Searching: MoMorph [iOS] Sun*Kudos_Searching      (hldqjHoSRH)
//
// Public contract:
//   SearchSunnerView(query:isSearching:results:onQueryChange:onSelect:)
//
// Purely presentational — NO service calls, NO ViewModel ownership.
// Sub-components live in SearchSunnerSubviews.swift.

import SwiftUI

struct SearchSunnerView: View {
    let query: String
    let isSearching: Bool
    let results: [User]
    var recentUsers: [User] = []
    let onQueryChange: (String) -> Void
    let onSelect: (User) -> Void
    var onRemoveRecent: (User) -> Void = { _ in }

    var body: some View {
        ZStack(alignment: .topLeading) {
            SearchSunnerBackground()

            VStack(spacing: 0) {
                Spacer().frame(height: 47) // Figma: status bar region top
                topNavigation
                contentArea.padding(.top, 12)
                Spacer()
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Top Navigation

    // Figma _TopNavigation-content: 375×40, padding trailing 20, gap 12
    private var topNavigation: some View {
        HStack(spacing: 12) {
            backButton
            searchBarField
        }
        .frame(height: 40)
        .padding(.trailing, 20)
    }

    // Figma left accessory: 40×42, padding 9/9/9/7; mm_media_back = chevron.left 24×24
    private var backButton: some View {
        Button(action: {}) {
            Image(systemName: "chevron.left")
                .font(.system(size: 17, weight: .regular))
                .foregroundStyle(Color.white)
                .frame(width: 24, height: 24)
        }
        .frame(width: 40, height: 42)
        .padding(.leading, 7)
        .padding([.trailing, .vertical], 9)
    }

    // Figma search bar: border #998C5F 1pt, bg rgba(255,234,158,0.10), radius 4, padding 10
    private var searchBarField: some View {
        HStack(spacing: 8) {
            TextField("", text: Binding(
                get: { query },
                set: { onQueryChange($0) }
            ), prompt: Text("Search Sunner")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color.white.opacity(0.8))
            )
            .font(.custom("Montserrat", size: 14))
            .fontWeight(.medium)
            .foregroundStyle(Color.white.opacity(0.8))
            .autocorrectionDisabled()
            .textInputAutocapitalization(.never)

            if isSearching {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.white.opacity(0.8))
                    .scaleEffect(0.75)
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity)
        .background(Color(hex: "FFEA9E").opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color(hex: "998C5F"), lineWidth: 1))
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        if query.trimmingCharacters(in: .whitespaces).isEmpty {
            idleContent
        } else {
            resultsContent
        }
    }

    // Idle: "Recent" header + "View all" + recent rows with × buttons
    // Figma Title row: 375×32, padding h20; search result rows: 60pt height
    private var idleContent: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Recent")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.white)
                    .frame(height: 32)
                Spacer()
                Button(action: {}) {
                    Text("View all ")
                        .font(.custom("Montserrat", size: 14))
                        .fontWeight(.medium)
                        .foregroundStyle(Color.white)
                        .frame(height: 32)
                }
            }
            .padding(.horizontal, 20)

            ForEach(recentUsers) { user in
                SearchRecentRow(user: user, onSelect: { onSelect(user) }, onRemove: { onRemoveRecent(user) })
            }
        }
    }

    // Results: rows only — no "Recent" header, no × buttons
    private var resultsContent: some View {
        VStack(spacing: 0) {
            if results.isEmpty && !isSearching {
                SearchEmptyResults()
            } else {
                ForEach(results) { user in
                    SunnerResultRow(user: user, onTap: { onSelect(user) })
                        .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Preview Sample Data (file-private)

private enum SearchSunnerPreviewData {
    static let recentUsers: [User] = [
        User(id: "u1", name: "Dương Huỳnh Xuân Nhật", departmentName: "CECV1"),
        User(id: "u2", name: "Dương Huỳnh Xuân Nhật", departmentName: "CECV1")
    ]
    static let resultUsers: [User] = [
        User(id: "u1", name: "Dương Huỳnh Xuân Nhật", departmentName: "CECV1"),
        User(id: "u2", name: "Dương Huỳnh Xuân Nhân", departmentName: "CECV1")
    ]
}

// MARK: - Previews

#Preview("Idle — no query") {
    SearchSunnerView(query: "", isSearching: false, results: [],
                     recentUsers: SearchSunnerPreviewData.recentUsers,
                     onQueryChange: { _ in }, onSelect: { _ in })
}

#Preview("Searching — loading spinner") {
    SearchSunnerView(query: "Dương", isSearching: true, results: [],
                     onQueryChange: { _ in }, onSelect: { _ in })
}

#Preview("Results") {
    SearchSunnerView(query: "Dương", isSearching: false,
                     results: SearchSunnerPreviewData.resultUsers,
                     onQueryChange: { _ in }, onSelect: { _ in })
}

#Preview("Empty results") {
    SearchSunnerView(query: "xyz", isSearching: false, results: [],
                     onQueryChange: { _ in }, onSelect: { _ in })
}
