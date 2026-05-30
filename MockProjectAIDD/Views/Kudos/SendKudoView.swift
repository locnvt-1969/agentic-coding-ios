// SendKudoView.swift
// MockProjectAIDD
//
// Gửi / Viết Kudo compose screen — pixel-perfect from Figma screens:
//   7fFAb-K35a  (default)         PV7jBVZU1N  (full form)
//   5MU728Tjck  (recipient drop)  aKWA2klsnt  (hashtag drop)
//   0le8xKnFE_  (validation error)
//
// Presentational only: all state lives in SendKudoViewModel (parent).
// No service calls, no Supabase imports, no ViewModel ownership here.
// Editable fields surface via @Binding; lists/callbacks passed by value.

import SwiftUI

// MARK: - SendKudoView

struct SendKudoView: View {
    // Recipients
    let recipients: [User]
    let availableRecipients: [User]

    // Hashtags
    let selectedHashtags: [Hashtag]
    let availableHashtags: [Hashtag]

    // Bound fields
    @Binding var awardText: String  // Parent/VM owns awardText; wired into SendKudoPayload during phase-19 integration.
    @Binding var message: String
    @Binding var isAnonymous: Bool

    // Validation (nil = no error)
    let validationError: String?

    // Callbacks
    var onAddRecipient: (User) -> Void
    var onAddHashtag: (Hashtag) -> Void
    var onRemoveHashtag: (Hashtag) -> Void
    var onSubmit: () -> Void
    var onCancel: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            // Background gradient matching Figma key-visual bg
            Color(hex: "00101A")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Top navigation bar
                SendKudoNavBar(onBack: onCancel)

                // Scrollable form content
                ScrollView {
                    VStack(spacing: 24) {
                        SendKudoFormCard(
                            availableRecipients: availableRecipients,
                            recipients: recipients,
                            onAddRecipient: onAddRecipient,
                            awardText: $awardText,
                            message: $message,
                            selectedHashtags: selectedHashtags,
                            availableHashtags: availableHashtags,
                            onAddHashtag: onAddHashtag,
                            onRemoveHashtag: onRemoveHashtag,
                            isAnonymous: $isAnonymous,
                            validationError: validationError
                        )

                        // Action buttons row
                        SendKudoActionButtons(
                            onCancel: onCancel,
                            onSubmit: onSubmit
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - SendKudoNavBar

/// Top navigation bar for the Send Kudo screen.
/// Design: title "Viết KUDO" centred, back chevron left, transparent/dark bg.
/// Values: title 16px Montserrat SemiBold white, height 44pt + status bar safe area.
private struct SendKudoNavBar: View {
    var onBack: () -> Void

    var body: some View {
        HStack {
            Button(action: onBack) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(Color.white)
            }
            .frame(width: 44, height: 44)

            Spacer()

            Text("Viết KUDO")
                .font(.custom("Montserrat", size: 16))
                .fontWeight(.semibold)
                .foregroundStyle(Color.white)

            Spacer()

            // Invisible spacer to balance back button
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 8)
        .frame(height: 44)
        .background(Color.clear)
    }
}

// MARK: - SendKudoActionButtons

/// Cancel + Submit button row at the bottom of the form.
/// Design (from Figma actions frame):
///   Cancel:  flex-1, #FFEA9E 10% bg, #998C5F 1px border, 4px radius, white label 14px
///   Submit:  160px, #FFEA9E fill, 4px radius, kudosDark label 14px
private struct SendKudoActionButtons: View {
    var onCancel: () -> Void
    var onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Cancel button — outline style
            Button(action: onCancel) {
                Text("Huỷ")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
                    .background(Color.kudosAccent.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.kudosBorderMuted, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)

            // Submit button — filled yellow
            Button(action: onSubmit) {
                Text("Gửi đi")
                    .font(.custom("Montserrat", size: 14))
                    .fontWeight(.medium)
                    .foregroundStyle(Color.kudosDark)
                    .frame(width: 160, height: 40)
                    .background(Color.kudosAccent)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Previews

private let _previewHashtags = ["#High-performing","#BE PROFESSIONAL","#BE OPTIMISTIC","#BE A TEAM","#THINK OUTSIDE THE BOX","#GET RISKY","#GO FAST","#WASSHOI"]
    .enumerated().map { Hashtag(id: "h\($0.offset)", name: $0.element, group: nil) }
private let _previewRecipients = [
    User(id: "u1", name: "Dương Huỳnh Xuân Nhật", departmentName: "CECV1"),
    User(id: "u2", name: "Dương Huỳnh Xuân Nhân", departmentName: "CECV1")
]

#Preview("Default state") {
    SendKudoView(
        recipients: [], availableRecipients: _previewRecipients,
        selectedHashtags: [], availableHashtags: _previewHashtags,
        awardText: .constant(""), message: .constant(""), isAnonymous: .constant(false),
        validationError: nil,
        onAddRecipient: { _ in }, onAddHashtag: { _ in }, onRemoveHashtag: { _ in },
        onSubmit: {}, onCancel: {}
    )
}

#Preview("Validation error state") {
    SendKudoView(
        recipients: [], availableRecipients: [],
        selectedHashtags: [_previewHashtags[0]], availableHashtags: _previewHashtags,
        awardText: .constant(""), message: .constant(""), isAnonymous: .constant(false),
        validationError: "Bạn cần điền đủ Người nhận, Lời nhắn gửi và Hashtag để gửi Kudos!",
        onAddRecipient: { _ in }, onAddHashtag: { _ in }, onRemoveHashtag: { _ in },
        onSubmit: {}, onCancel: {}
    )
}
