// ViewKudoCommentsSection.swift
// MockProjectAIDD
//
// Comments section for the Kudo detail screen:
//   • ViewKudoCommentsSection — section header + list + input field
//   • ViewKudoCommentRow      — single comment bubble

import SwiftUI

// MARK: - ViewKudoCommentsSection

struct ViewKudoCommentsSection: View {
    let comments: [KudoComment]
    @Binding var commentText: String
    var onSubmit: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text("Bình luận")
                .font(.custom("Montserrat", size: 12))
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)

            // Existing comments list
            if comments.isEmpty {
                Text("Chưa có bình luận.")
                    .font(.custom("Montserrat", size: 10))
                    .foregroundStyle(Color.kudosMuted)
                    .padding(.vertical, 4)
            } else {
                VStack(spacing: 8) {
                    ForEach(comments) { comment in
                        ViewKudoCommentRow(comment: comment)
                    }
                }
            }

            // Comment input
            HStack(spacing: 8) {
                TextField("Thêm bình luận...", text: $commentText)
                    .font(.custom("Montserrat", size: 10))
                    .foregroundStyle(Color.kudosDark)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 8)
                    .background(Color.kudosCardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.kudosBorder, lineWidth: 0.5)
                    )
                    .onSubmit { onSubmit() }

                Button(action: onSubmit) {
                    Image(systemName: "paperplane.fill")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.kudosPrimary)
                }
                .buttonStyle(.plain)
                .disabled(commentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}

// MARK: - ViewKudoCommentRow

struct ViewKudoCommentRow: View {
    let comment: KudoComment

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .short
        f.timeStyle = .short
        return f
    }()

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            // Author avatar
            ZStack {
                Circle()
                    .fill(Color(hex: "EEEEEE"))
                    .frame(width: 24, height: 24)
                    .overlay(Circle().stroke(Color.white, lineWidth: 0.865))

                if let url = comment.author.avatarURL {
                    AsyncImage(url: url) { phase in
                        if case .success(let img) = phase {
                            img.resizable().scaledToFill()
                        } else {
                            Color(hex: "EEEEEE")
                        }
                    }
                    .frame(width: 24, height: 24)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(Color.kudosMuted)
                }
            }
            .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(comment.author.name)
                        .font(.custom("Montserrat", size: 10))
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.white)

                    Text(Self.dateFormatter.string(from: comment.createdAt))
                        .font(.custom("Montserrat", size: 8))
                        .foregroundStyle(Color.kudosMuted)
                }

                Text(comment.text)
                    .font(.custom("Montserrat", size: 10))
                    .foregroundStyle(Color.kudosDark)
                    .padding(6)
                    .background(Color.kudosCardBg)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }

            Spacer()
        }
    }
}
