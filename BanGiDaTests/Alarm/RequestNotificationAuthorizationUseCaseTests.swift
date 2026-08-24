import Foundation
import Testing
import Domain

@testable import BanGiDa

struct RequestNotificationAuthorizationUseCaseTests {
    @Test func returnsTrueWhenRepositoryGrantsAuthorization() async {
        let (sut, notificationRepository) = makeSUT()
        notificationRepository.requestAuthorizationReturnValue = true

        let result = await sut.execute()

        #expect(result == true)
    }

    @Test func returnsFalseWhenRepositoryDeniesAuthorization() async {
        let (sut, notificationRepository) = makeSUT()
        notificationRepository.requestAuthorizationReturnValue = false

        let result = await sut.execute()

        #expect(result == false)
    }

    @Test func delegatesExactlyOnceToRepository() async {
        let (sut, notificationRepository) = makeSUT()

        _ = await sut.execute()

        #expect(notificationRepository.requestAuthorizationCallCount == 1)
    }
}

private func makeSUT() -> (RequestNotificationAuthorizationUseCaseImpl, MockNotificationRepository) {
    let notificationRepository = MockNotificationRepository()
    let sut = RequestNotificationAuthorizationUseCaseImpl(notificationRepository: notificationRepository)

    return (sut, notificationRepository)
}
