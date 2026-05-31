// SendKudoFormCard.swift
// MockProjectAIDD
//
// Presentational card containing all Kudo compose fields.
// Purely presentational — all state owned by SendKudoViewModel (parent).
// Design: #FFF8E1 card bg, #998C5F borders, Montserrat font.

import SwiftUI

// MARK: - SendKudoFormCard

struct SendKudoFormCard: View {
    // Recipient (single per kudo)
    let availableRecipients: [User]
    let selectedRecipient: User?
    var onSelectRecipient: (User) -> Void

    // Award (danh hiệu) — uses same search-field style
    @Binding var awardText: String

    // Message
    @Binding var message: String

    // Hashtags
    let selectedHashtags: [Hashtag]
    let availableHashtags: [Hashtag]
    var onAddHashtag: (Hashtag) -> Void
    var onRemoveHashtag: (Hashtag) -> Void

    // Awards info / community standards link (spec B.5)
    var onCommunityStandards: () -> Void

    // Anonymous
    @Binding var isAnonymous: Bool

    // Validation
    let validationError: String?

    // Dropdown state — owned here as local UI state
    @State private var showRecipientDropdown = false
    @State private var showHashtagDropdown = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Title
            Text("Gửi lời cám ơn và ghi nhận đến đồng đội")
                .font(.custom("Montserrat", size: 14))
                .fontWeight(.bold)
                .foregroundStyle(Color.kudosDark)
                .frame(maxWidth: .infinity, alignment: .center)

            // Người nhận field — shows the chosen recipient's name; tap opens the picker.
            SendKudoFieldRow(label: "Người nhận", isRequired: true) {
                SendKudoSearchField(
                    placeholder: "Tìm kiếm",
                    text: .constant(selectedRecipient?.name ?? ""),
                    onTap: { showRecipientDropdown = true }
                )
            }

            // Danh hiệu field — editable text input (spec B.4)
            SendKudoFieldRow(label: "Danh hiệu", isRequired: true) {
                SendKudoTextField(
                    placeholder: "Dành tặng một danh hiệu cho...",
                    text: $awardText
                )
            }

            // Award hint text
            Text("Ví dụ: Người truyền động lực cho tôi.\nDanh hiệu sẽ hiển thị làm tiêu đề Kudos của bạn.")
                .font(.custom("Montserrat", size: 12))
                .fontWeight(.regular)
                .foregroundStyle(Color.kudosMuted)
                .lineSpacing(4)

            // mms_B.5 — Awards info / community standards link (spec B.5)
            Button(action: onCommunityStandards) {
                Text("Tiêu chuẩn cộng đồng")
                    .font(.custom("Montserrat", size: 12))
                    .fontWeight(.medium)
                    .underline()
                    .foregroundStyle(Color.kudosDark)
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity, alignment: .leading)

            // Message text area
            SendKudoMessageField(message: $message)

            // Hashtag field
            SendKudoHashtagRow(
                selectedHashtags: selectedHashtags,
                availableHashtags: availableHashtags,
                onRemove: onRemoveHashtag,
                onTapAdd: { showHashtagDropdown = true }
            )

            // Image row (static — upload is phase-19 logic)
            SendKudoImageRow()

            // Anonymous toggle
            SendKudoAnonymousRow(isAnonymous: $isAnonymous)

            // Validation error
            if let error = validationError {
                Text(error)
                    .font(.custom("Montserrat", size: 12))
                    .fontWeight(.regular)
                    .foregroundStyle(Color(hex: "D4271D"))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity)
        .background(Color.kudosBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10.72))
        // Recipient dropdown overlay
        .overlay(alignment: .topTrailing) {
            if showRecipientDropdown {
                SendKudoRecipientDropdown(
                    items: availableRecipients,
                    onSelect: { user in
                        onSelectRecipient(user)
                        showRecipientDropdown = false
                    },
                    onDismiss: { showRecipientDropdown = false }
                )
                .padding(.top, 56) // approx offset below recipient row
                .padding(.trailing, 0)
                .transition(.opacity)
            }
        }
        // Hashtag dropdown overlay
        .overlay(alignment: .topTrailing) {
            if showHashtagDropdown {
                SendKudoHashtagDropdown(
                    items: availableHashtags,
                    selectedHashtags: selectedHashtags,
                    onSelect: { hashtag in
                        onAddHashtag(hashtag)
                    },
                    onDismiss: { showHashtagDropdown = false }
                )
                .padding(.top, 240) // approx offset below hashtag row
                .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.15), value: showRecipientDropdown)
        .animation(.easeInOut(duration: 0.15), value: showHashtagDropdown)
    }
}

// SendKudoFieldRow and SendKudoSearchField live in SendKudoFormFields.swift
