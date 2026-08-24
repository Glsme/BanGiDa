import Foundation
import Testing

@testable import BanGiDa

struct UpdateAlarmUseCaseTests {
    @Test func callsUpdateThenRemoveThenScheduleInOrderWhenScheduleConditionIsMet() throws {
        let (sut, diaryRepository, _) = makeSUT()
        let entry = makeDiaryEntry(type: .alarm, date: Date().addingTimeInterval(3600), repeatRule: .none)

        _ = try sut.execute(entry: entry)

        #expect(diaryRepository.callRecorder?.events == ["update", "remove", "schedule"])
    }

    // 캡처: 과거 날짜 + repeatRule .none이면 remove만 호출되고 schedule은 호출되지 않는다.
    @Test func callsUpdateThenRemoveOnlyWhenScheduleConditionIsNotMet() throws {
        let (sut, diaryRepository, _) = makeSUT()
        let entry = makeDiaryEntry(type: .alarm, date: Date().addingTimeInterval(-3600), repeatRule: .none)

        _ = try sut.execute(entry: entry)

        #expect(diaryRepository.callRecorder?.events == ["update", "remove"])
    }

    @Test func removesExistingNotificationByEntryID() throws {
        let (sut, _, notificationRepository) = makeSUT()
        let entry = makeDiaryEntry(id: "alarm-id", type: .alarm, date: Date().addingTimeInterval(-3600), repeatRule: .none)

        _ = try sut.execute(entry: entry)

        #expect(notificationRepository.removedIdentifiers == ["alarm-id"])
    }

    @Test func schedulesWhenDateIsInFutureAndRepeatRuleIsNone() throws {
        let (sut, _, notificationRepository) = makeSUT()
        let entry = makeDiaryEntry(type: .alarm, date: Date().addingTimeInterval(3600), repeatRule: .none)

        _ = try sut.execute(entry: entry)

        #expect(notificationRepository.scheduledNotifications.count == 1)
    }

    @Test func doesNotScheduleWhenDateIsInPastAndRepeatRuleIsNone() throws {
        let (sut, _, notificationRepository) = makeSUT()
        let entry = makeDiaryEntry(type: .alarm, date: Date().addingTimeInterval(-3600), repeatRule: .none)

        _ = try sut.execute(entry: entry)

        #expect(notificationRepository.scheduledNotifications.isEmpty)
    }

    @Test func schedulesWhenDateIsInPastButRepeatRuleIsNotNone() throws {
        let (sut, _, notificationRepository) = makeSUT()
        let entry = makeDiaryEntry(type: .alarm, date: Date().addingTimeInterval(-3600), repeatRule: .daily)

        _ = try sut.execute(entry: entry)

        #expect(notificationRepository.scheduledNotifications.count == 1)
    }

    @Test func schedulesWithEntryIDContentDateAndRepeatRule() throws {
        let (sut, _, notificationRepository) = makeSUT()
        let date = Date().addingTimeInterval(3600)
        let entry = makeDiaryEntry(id: "alarm-id", type: .alarm, date: date, content: "산책 다녀오기", repeatRule: .weekly)

        _ = try sut.execute(entry: entry)

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.identifier == "alarm-id")
        #expect(scheduled.body == "산책 다녀오기")
        #expect(scheduled.date == date)
        #expect(scheduled.repeatRule == .weekly)
    }

    @Test func usesAlarmTitleAsScheduleTitleWhenPresent() throws {
        let (sut, _, notificationRepository) = makeSUT()
        let entry = makeDiaryEntry(
            type: .alarm,
            date: Date().addingTimeInterval(3600),
            animalName: "댕댕이",
            alarmTitle: "복약 알림",
            repeatRule: .none
        )

        _ = try sut.execute(entry: entry)

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.title == "복약 알림")
    }

    // 캡처: alarmTitle이 nil이면 animalName으로 대체된다. SaveAlarmUseCase는
    // alarmTitle을 그대로 title에 쓰지만(필수 인자라 nil이 될 수 없음),
    // UpdateAlarmUseCase는 이 대체 로직이 있다는 차이가 있다.
    @Test func fallsBackToAnimalNameAsScheduleTitleWhenAlarmTitleIsNil() throws {
        let (sut, _, notificationRepository) = makeSUT()
        let entry = makeDiaryEntry(
            type: .alarm,
            date: Date().addingTimeInterval(3600),
            animalName: "댕댕이",
            alarmTitle: nil,
            repeatRule: .none
        )

        _ = try sut.execute(entry: entry)

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.title == "댕댕이")
    }

    // 캡처: update가 throw하면 remove도 schedule도 호출되지 않는다. 즉 기존에
    // 걸려 있던 알림은 갱신되지 않은 채 그대로 살아남는다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func doesNotRemoveOrScheduleWhenUpdateThrows() {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        diaryRepository.updateError = TestError.failure
        let entry = makeDiaryEntry(type: .alarm, date: Date().addingTimeInterval(3600), repeatRule: .none)

        #expect(throws: TestError.self) {
            try sut.execute(entry: entry)
        }

        #expect(notificationRepository.removedIdentifiers.isEmpty)
        #expect(notificationRepository.scheduledNotifications.isEmpty)
    }

    // 캡처: update는 반환값이 없으므로, 이 UseCase는 저장소가 가공한 값이 아니라
    // 인자로 받은 entry를 그대로 반환한다.
    @Test func returnsInputEntryUnchanged() throws {
        let (sut, _, _) = makeSUT()
        let entry = makeDiaryEntry(id: "alarm-id", type: .alarm, date: Date().addingTimeInterval(3600), content: "내용", repeatRule: .none)

        let result = try sut.execute(entry: entry)

        #expect(result.id == entry.id)
        #expect(result.content == entry.content)
        #expect(result.date == entry.date)
    }
}

private func makeSUT() -> (UpdateAlarmUseCaseImpl, MockDiaryRepository, MockNotificationRepository) {
    let recorder = CallRecorder()
    let diaryRepository = MockDiaryRepository()
    diaryRepository.callRecorder = recorder
    let notificationRepository = MockNotificationRepository()
    notificationRepository.callRecorder = recorder

    let sut = UpdateAlarmUseCaseImpl(diaryRepository: diaryRepository, notificationRepository: notificationRepository)

    return (sut, diaryRepository, notificationRepository)
}
