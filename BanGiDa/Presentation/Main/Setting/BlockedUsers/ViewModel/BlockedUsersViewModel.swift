//
//  BlockedUsersViewModel.swift
//  BanGiDa
//

import Combine
import Foundation

@MainActor
final class BlockedUsersViewModel: ObservableObject {
    @Injected private var analyticsRepository: AnalyticsRepository
    @Injected private var fetchBlockedUsersUseCase: FetchBlockedUsersUseCase
    @Injected private var unblockUserUseCase: UnblockUserUseCase

    @Published private(set) var blockedUsers: [BlockedUser] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private var hasLoadedOnce = false

    func loadInitialIfNeeded() {
        guard !hasLoadedOnce else { return }
        hasLoadedOnce = true

        Task { await fetchBlockedUsers() }
    }

    func unblock(user: BlockedUser) {
        guard let index = blockedUsers.firstIndex(of: user) else { return }

        blockedUsers.remove(at: index)

        Task {
            do {
                try await unblockUserUseCase.execute(targetUID: user.id)
                errorMessage = nil
            } catch {
                blockedUsers.insert(user, at: min(index, blockedUsers.count))
                errorMessage = "차단을 해제하지 못했어요. 다시 시도해 주세요."
                analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])
            }
        }
    }

    // MARK: - Private

    private func fetchBlockedUsers() async {
        guard !isLoading else { return }
        isLoading = true

        defer { isLoading = false }

        do {
            blockedUsers = try await fetchBlockedUsersUseCase.execute()
            errorMessage = nil
        } catch {
            errorMessage = "차단 목록을 불러오지 못했어요. 다시 시도해 주세요."
            analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])
        }
    }
}
