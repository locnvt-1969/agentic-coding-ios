// SendKudoContainer.swift
// MockProjectAIDD
//
// Container: wires SendKudoViewModel → SendKudoView.
// Mock recipients/hashtags + simulated submit under FeatureFlags.useMockKudoData.

import SwiftUI

struct SendKudoContainer: View {
    @State private var vm = SendKudoViewModel()
    @State private var showCancelConfirm = false
    @EnvironmentObject private var router: AppRouter

    var body: some View {
        // Derive @Bindable locally from @State so bindings always reference
        // the live @State instance — avoids divergence on struct re-init.
        @Bindable var vm = vm
        SendKudoView(
            selectedRecipient: vm.selectedRecipient,
            availableRecipients: vm.availableRecipients,
            selectedHashtags: vm.selectedHashtags,
            availableHashtags: vm.availableHashtags,
            awardText: $vm.title,          // Danh hiệu → kudo title
            message: $vm.message,
            isAnonymous: $vm.isAnonymous,
            validationError: vm.validationError,
            onSelectRecipient: { vm.selectRecipient($0) },
            onAddHashtag: { vm.addHashtag($0) },
            onRemoveHashtag: { vm.removeHashtag($0) },
            onCommunityStandards: { router.push(.communityStandards) },
            onSubmit: {
                Task {
                    await vm.submit()
                    if vm.didSend {
                        ToastCenter.shared.show("Gửi Kudo thành công")
                        router.pop()
                    }
                }
            },
            onCancel: {
                if vm.hasUnsavedContent {
                    showCancelConfirm = true
                } else {
                    router.pop()
                }
            }
        )
        .task {
            await vm.loadOptions()
        }
        .confirmationDialog(
            "Huỷ viết Kudo?",
            isPresented: $showCancelConfirm,
            titleVisibility: .visible
        ) {
            Button("Thoát, không lưu", role: .destructive) { router.pop() }
            Button("Tiếp tục viết", role: .cancel) {}
        } message: {
            Text("Nội dung chưa gửi sẽ bị mất.")
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
