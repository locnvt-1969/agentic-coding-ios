// SunnerResultRow.swift
// MockProjectAIDD
//
// Presentational row for a single search result in Search Sunner.
// Design source: MoMorph [iOS] Sun*Kudos_Search Sunner (3jgwke3E8O)
// Row: avatar (40x40, circular, white border 1.869pt) + name + department label.
// Purely presentational — exposes onTap callback only.

import SwiftUI

struct SunnerResultRow: View {
    let user: User
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 2) {
                avatarView
                nameStack
                Spacer()
            }
            .frame(height: 60)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Subviews

    private var avatarView: some View {
        ZStack {
            Circle()
                .fill(Color(hex: "EEEEEE"))
                .frame(width: 40, height: 40)

            if let url = user.avatarURL {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        placeholderAvatar
                    }
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                placeholderAvatar
            }
        }
        .frame(width: 40, height: 40)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(Color.white, lineWidth: 1.869)
        )
        .frame(width: 60, height: 60) // matches Figma Avatar container (60x60 with 10pt padding)
    }

    private var placeholderAvatar: some View {
        Image("SampleAvatar", bundle: nil)
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
    }

    private var nameStack: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(user.name)
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color.white)
                .lineLimit(1)
                .frame(height: 20)

            Text(user.departmentName ?? user.level ?? "")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.medium)
                .foregroundStyle(Color(hex: "999999"))
                .lineLimit(1)
                .frame(height: 20)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Previews

#Preview("Row with avatar URL") {
    SunnerResultRow(
        user: User(
            id: "u1",
            name: "Dương Huỳnh Xuân Nhật",
            avatarURL: nil,
            departmentName: "CECV1"
        ),
        onTap: {}
    )
    .padding(.horizontal, 20)
    .background(Color(hex: "00101A"))
}

#Preview("Row no avatar") {
    SunnerResultRow(
        user: User(
            id: "u2",
            name: "Dương Huỳnh Xuân Nhân",
            avatarURL: nil,
            departmentName: "CECV1"
        ),
        onTap: {}
    )
    .padding(.horizontal, 20)
    .background(Color(hex: "00101A"))
}
