import Foundation
import Testing
import Domain

@testable import BanGiDa

struct UpdateFCMTokenUseCaseTests {
    @Test func savesTokenImmediatelyWhenUIDExists() async throws {
        let userRepository = MockUserRepository()
        userRepository.uid = "user-uid"
        let userDefaults = makeUserDefaults()
        let useCase = UpdateFCMTokenUseCaseImpl(
            userRepository: userRepository,
            userDefaults: userDefaults
        )

        try await useCase.execute(token: "fcm-token")

        #expect(userRepository.updatedFCMTokens == ["fcm-token"])
    }

    @Test func savesPendingTokenAfterUIDBecomesAvailable() async throws {
        let userRepository = MockUserRepository()
        let userDefaults = makeUserDefaults()
        let useCase = UpdateFCMTokenUseCaseImpl(
            userRepository: userRepository,
            userDefaults: userDefaults
        )

        try await useCase.execute(token: "pending-token")

        #expect(userRepository.updatedFCMTokens.isEmpty)

        userRepository.uid = "user-uid"
        try await useCase.flushPendingToken()

        #expect(userRepository.updatedFCMTokens == ["pending-token"])
    }

    @Test func skipsSavingAnUnchangedTokenForTheSameUser() async throws {
        let userRepository = MockUserRepository()
        userRepository.uid = "user-uid"
        let userDefaults = makeUserDefaults()
        let useCase = UpdateFCMTokenUseCaseImpl(
            userRepository: userRepository,
            userDefaults: userDefaults
        )

        try await useCase.execute(token: "unchanged-token")
        try await useCase.execute(token: "unchanged-token")

        #expect(userRepository.updatedFCMTokens == ["unchanged-token"])
    }
}

@Suite(.serialized)
struct SettingViewModelCommentNotificationTests {
    @MainActor
    @Test func forwardsChangedValueToUserRepository() async {
        let userRepository = MockUserRepository()
        userRepository.uid = "user-uid"
        let viewModel = makeSettingViewModel(userRepository: userRepository)

        viewModel.setCommentNotificationEnabled(false)
        await waitUntil {
            userRepository.updatedCommentNotificationEnabledValues == [false]
        }

        #expect(userRepository.updatedCommentNotificationEnabledValues == [false])
        #expect(viewModel.isCommentNotificationEnabled == false)
    }
}

private func makeUserDefaults() -> UserDefaults {
    let suiteName = "UpdateFCMTokenUseCaseTests.\(UUID().uuidString)"
    let userDefaults = UserDefaults(suiteName: suiteName)!
    userDefaults.removePersistentDomain(forName: suiteName)
    return userDefaults
}

@MainActor
private func makeSettingViewModel(userRepository: MockUserRepository) -> SettingViewModel {
    AppDIContainer.shared.container.register(ResetDataUseCase.self) { _ in
        MockResetDataUseCase()
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(RestoreNotificationsUseCase.self) { _ in
        MockRestoreNotificationsUseCase()
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(UserPreferencesUseCase.self) { _ in
        MockUserPreferencesUseCase()
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(CommentNotificationSettingsUseCase.self) { _ in
        CommentNotificationSettingsUseCaseImpl(userRepository: userRepository)
    }
    .inObjectScope(.transient)

    return SettingViewModel()
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
