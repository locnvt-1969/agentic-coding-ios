// SendKudoContainer.swift
// MockProjectAIDD
//
// Container: wires SendKudoViewModel → SendKudoView.
// awardText is held locally — SendKudoViewModel has no awardText property.
// TODO phase-19+: wire awardText into SendKudoPayload/VM when the VM adds support.
// Phase-19 integration.

import SwiftUI

struct SendKudoContainer: View {
    @State private var vm = SendKudoViewModel()
    @State private var awardText = ""
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        // Derive @Bindable locally from @State so bindings always reference
        // the live @State instance — avoids divergence on struct re-init.
        @Bindable var vm = vm
        SendKudoView(
            recipients: vm.recipients,
            availableRecipients: vm.availableRecipients,
            selectedHashtags: vm.selectedHashtags,
            availableHashtags: vm.availableHashtags,
            awardText: $awardText,
            message: $vm.message,
            isAnonymous: $vm.isAnonymous,
            validationError: vm.validationError,
            onAddRecipient: { user in
                if !vm.recipients.contains(where: { $0.id == user.id }) {
                    vm.recipients.append(user)
                }
            },
            onAddHashtag: { hashtag in
                if !vm.selectedHashtags.contains(where: { $0.id == hashtag.id }) {
                    vm.selectedHashtags.append(hashtag)
                }
            },
            onRemoveHashtag: { hashtag in
                vm.selectedHashtags.removeAll { $0.id == hashtag.id }
            },
            onSubmit: {
                Task {
                    await vm.submit()
                    if vm.didSend { router.pop() }
                }
            },
            onCancel: {
                router.pop()
            }
        )
        .task {
            await vm.loadOptions()
        }
        .alert(
            "Lỗi",
            isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}
