import Foundation
import Testing

@testable import BanGiDa

struct RemoveNotificationUseCaseTests {
    @Test func delegatesToRemoveByIdentifier() {
        let (sut, notificationRepository) = makeSUT()

        sut.execute(identifier: "alarm-id")

        #expect(notificationRepository.removedIdentifiers == ["alarm-id"])
    }

    @Test func byIdentifierOverloadDoesNotCallByIndexOverload() {
        let (sut, notificationRepository) = makeSUT()

        sut.execute(identifier: "alarm-id")

        #expect(notificationRepository.removedNotificationsByIndex.isEmpty)
    }

    @Test func delegatesToRemoveByIndexWithArgumentsUnchanged() throws {
        let (sut, notificationRepository) = makeSUT()
        let date = Date().addingTimeInterval(3600)

        sut.execute(title: "제목", body: "내용", date: date, index: 2, repeatRule: .monthly)

        let removed = try #require(notificationRepository.removedNotificationsByIndex.first)
        #expect(removed.title == "제목")
        #expect(removed.body == "내용")
        #expect(removed.date == date)
        #expect(removed.index == 2)
        #expect(removed.repeatRule == .monthly)
    }

    @Test func byIndexOverloadDoesNotCallByIdentifierOverload() {
        let (sut, notificationRepository) = makeSUT()

        sut.execute(title: "제목", body: "내용", date: Date(), index: 0, repeatRule: .none)

        #expect(notificationRepository.removedIdentifiers.isEmpty)
    }
}

private func makeSUT() -> (RemoveNotificationUseCaseImpl, MockNotificationRepository) {
    let notificationRepository = MockNotificationRepository()
    let sut = RemoveNotificationUseCaseImpl(notificationRepository: notificationRepository)

    return (sut, notificationRepository)
}
