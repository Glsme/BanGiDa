import Foundation
import Testing
import Domain

@testable import BanGiDa

struct FetchBlockedUsersUseCaseTests {
    @Test func forwardsRepositoryUsers() async throws {
        let userRepository = MockUserRepository()
        userRepository.uid = "my-uid"
        let expectedUsers = [
            BlockedUser(
                id: "blocked-uid",
                nickname: "차단 대상",
                blockedAt: Date(timeIntervalSince1970: 100),
                displayTime: "1970.01.01"
            )
        ]
        userRepository.blockedUsers = expectedUsers
        let useCase = FetchBlockedUsersUseCaseImpl(userRepository: userRepository)

        let users = try await useCase.execute()

        #expect(users == expectedUsers)
    }

    @Test func substitutesUnknownNicknameWhenRepositoryNicknameIsEmpty() async throws {
        let userRepository = MockUserRepository()
        userRepository.uid = "my-uid"
        userRepository.blockedUsers = [
            BlockedUser(
                id: "blocked-uid",
                nickname: "",
                blockedAt: Date(timeIntervalSince1970: 100),
                displayTime: "1970.01.01"
            )
        ]
        let useCase = FetchBlockedUsersUseCaseImpl(userRepository: userRepository)

        let users = try await useCase.execute()

        #expect(users.map(\.nickname) == ["알 수 없는 사용자"])
    }
}

@Suite(.serialized)
struct BlockedUsersViewModelTests {
    @MainActor
    @Test func removesUserImmediatelyWhenUnblockingSucceeds() async {
        let userRepository = MockUserRepository()
        userRepository.uid = "my-uid"
        userRepository.blockedUsers = [makeBlockedUser(id: "blocked-uid", nickname: "차단 대상")]
        let viewModel = makeBlockedUsersViewModel(userRepository: userRepository)

        viewModel.loadInitialIfNeeded()
        await waitUntil { viewModel.blockedUsers.count == 1 }
        let user = viewModel.blockedUsers[0]

        viewModel.unblock(user: user)
        await waitUntil {
            viewModel.blockedUsers.isEmpty && userRepository.unblockedUID == "blocked-uid"
        }

        #expect(viewModel.errorMessage == nil)
    }

    @MainActor
    @Test func restoresUserWhenUnblockingFails() async {
        let userRepository = MockUserRepository()
        userRepository.uid = "my-uid"
        userRepository.unblockError = TestCommentError.networkFailure
        let blockedUser = makeBlockedUser(id: "blocked-uid", nickname: "차단 대상")
        userRepository.blockedUsers = [blockedUser]
        let viewModel = makeBlockedUsersViewModel(userRepository: userRepository)

        viewModel.loadInitialIfNeeded()
        await waitUntil { viewModel.blockedUsers.count == 1 }

        viewModel.unblock(user: blockedUser)
        await waitUntil { viewModel.errorMessage != nil }

        #expect(viewModel.blockedUsers == [blockedUser])
        #expect(viewModel.errorMessage == "차단을 해제하지 못했어요. 다시 시도해 주세요.")
    }
}

@MainActor
private func makeBlockedUsersViewModel(
    userRepository: MockUserRepository
) -> BlockedUsersViewModel {
    AppDIContainer.shared.container.register(FetchBlockedUsersUseCase.self) { _ in
        FetchBlockedUsersUseCaseImpl(userRepository: userRepository)
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(UnblockUserUseCase.self) { _ in
        UnblockUserUseCaseImpl(userRepository: userRepository)
    }
    .inObjectScope(.transient)

    // @Injected는 생성 즉시 resolve하므로, 실제 Crashlytics가 불리지 않도록 Mock으로 덮는다.
    AppDIContainer.shared.container.register(AnalyticsRepository.self) { _ in
        MockAnalyticsRepository()
    }
    .inObjectScope(.transient)

    return BlockedUsersViewModel()
}

@MainActor
private func makeBlockedUser(id: String, nickname: String) -> BlockedUser {
    BlockedUser(
        id: id,
        nickname: nickname,
        blockedAt: Date(timeIntervalSince1970: 100),
        displayTime: "1970.01.01"
    )
}

@MainActor
private func waitUntil(_ condition: @escaping @MainActor () -> Bool) async {
    for _ in 0..<500 {
        if condition() {
            return
        }

        await Task.yield()
    }
}
