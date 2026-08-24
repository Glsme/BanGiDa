import Foundation
import Testing
import Domain

@testable import BanGiDa

struct ScheduleNotificationUseCaseTests {
    @Test func delegatesToScheduleByIdentifierWithArgumentsUnchanged() throws {
        let (sut, notificationRepository) = makeSUT()
        let date = Date().addingTimeInterval(3600)

        sut.execute(identifier: "alarm-id", title: "제목", body: "내용", date: date, repeatRule: .weekly)

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.identifier == "alarm-id")
        #expect(scheduled.title == "제목")
        #expect(scheduled.body == "내용")
        #expect(scheduled.date == date)
        #expect(scheduled.repeatRule == .weekly)
    }

    @Test func byIdentifierOverloadDoesNotCallByIndexOverload() {
        let (sut, notificationRepository) = makeSUT()

        sut.execute(identifier: "alarm-id", title: "제목", body: "내용", date: Date(), repeatRule: .none)

        #expect(notificationRepository.scheduledNotificationsByIndex.isEmpty)
    }

    @Test func delegatesToScheduleByIndexWithArgumentsUnchanged() throws {
        let (sut, notificationRepository) = makeSUT()
        let date = Date().addingTimeInterval(3600)

        sut.execute(title: "제목", body: "내용", date: date, index: 3, repeatRule: .daily)

        let scheduled = try #require(notificationRepository.scheduledNotificationsByIndex.first)
        #expect(scheduled.title == "제목")
        #expect(scheduled.body == "내용")
        #expect(scheduled.date == date)
        #expect(scheduled.index == 3)
        #expect(scheduled.repeatRule == .daily)
    }

    @Test func byIndexOverloadDoesNotCallByIdentifierOverload() {
        let (sut, notificationRepository) = makeSUT()

        sut.execute(title: "제목", body: "내용", date: Date(), index: 0, repeatRule: .none)

        #expect(notificationRepository.scheduledNotifications.isEmpty)
    }
}

private func makeSUT() -> (ScheduleNotificationUseCaseImpl, MockNotificationRepository) {
    let notificationRepository = MockNotificationRepository()
    let sut = ScheduleNotificationUseCaseImpl(notificationRepository: notificationRepository)

    return (sut, notificationRepository)
}
