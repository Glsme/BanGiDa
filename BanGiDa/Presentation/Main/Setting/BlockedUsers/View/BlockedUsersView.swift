//
//  BlockedUsersView.swift
//  BanGiDa
//

import SwiftUI

struct BlockedUsersView: View {
    @StateObject private var viewModel = BlockedUsersViewModel()

    var body: some View {
        contentView
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .navigationTitle("차단 목록")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.backgroundColor)
            .onAppear {
                viewModel.loadInitialIfNeeded()
            }
            .alert(
                "문제가 발생했어요",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.errorMessage = nil
                        }
                    }
                )
            ) {
                Button("확인", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
    }
}

private extension BlockedUsersView {
    @ViewBuilder
    var contentView: some View {
        if viewModel.isLoading && viewModel.blockedUsers.isEmpty {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.blockedUsers.isEmpty {
            VStack {
                Spacer()
                Text("차단한 사용자가 없어요")
                    .font(.custom("HelveticaNeue-Regular", size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(viewModel.blockedUsers) { user in
                        BlockedUserRow(
                            user: user,
                            onUnblock: { viewModel.unblock(user: user) }
                        )

                        Divider()
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

private struct BlockedUserRow: View {
    let user: BlockedUser
    let onUnblock: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(user.nickname)
                    .font(.custom("HelveticaNeue-Bold", size: 14))
                    .foregroundColor(Color.systemTintColor)

                Text(user.displayTime)
                    .font(.custom("HelveticaNeue-Regular", size: 12))
                    .foregroundColor(.secondary)
            }

            Spacer()

            Button(action: onUnblock) {
                Text("차단 해제")
                    .font(.custom("HelveticaNeue-Medium", size: 13))
                    .foregroundColor(Color.systemTintColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .overlay {
                        Capsule()
                            .stroke(Color.systemTintColor, lineWidth: 1)
                    }
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 14)
    }
}
