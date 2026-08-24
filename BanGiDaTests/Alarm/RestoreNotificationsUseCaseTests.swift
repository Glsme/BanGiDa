import Foundation
import Testing

@testable import BanGiDa

struct RestoreNotificationsUseCaseTests {
    @Test func fetchesOnlyAlarmTypeEntries() {
        let (sut, diaryRepository, _) = makeSUT()

        sut.execute()

        #expect(diaryRepository.requestedFetchByTypeType == .alarm)
    }

    @Test func callsRemoveAllPendingBeforeSchedulingWhenAlarmExists() {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        diaryRepository.entriesByType = [makeDiaryEntry(type: .alarm, date: Date().addingTimeInterval(3600))]

        sut.execute()

        #expect(notificationRepository.callRecorder?.events == ["removeAllPending", "schedule"])
    }

    // 캡처: 대기 중인 알람이 하나도 없으면 removeAllPending만 호출되고 schedule은 호출되지 않는다.
    @Test func doesNotScheduleAndOnlyRemovesAllPendingWhenNoAlarmsExist() {
        let (sut, _, notificationRepository) = makeSUT()

        sut.execute()

        #expect(notificationRepository.scheduledNotifications.isEmpty)
        #expect(notificationRepository.callRecorder?.events == ["removeAllPending"])
    }

    @Test func reschedulesOnlyFutureAlarms() {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        let futureAlarm = makeDiaryEntry(id: "future", type: .alarm, date: Date().addingTimeInterval(3600))
        let pastAlarm = makeDiaryEntry(id: "past", type: .alarm, date: Date().addingTimeInterval(-3600))
        diaryRepository.entriesByType = [futureAlarm, pastAlarm]

        sut.execute()

        #expect(notificationRepository.scheduledNotifications.map(\.identifier) == ["future"])
    }

    // 캡처(최우선 항목, 고치지 말 것): SaveAlarmUseCase/UpdateAlarmUseCase는
    // `date > now || repeatRule != .none` 조건으로 과거 날짜라도 반복 알람이면 예약하지만,
    // RestoreNotificationsUseCase는 `date > now`만 본다. 그 결과 과거 날짜에 걸린
    // 반복 알람은 앱 재시작(알림 복원) 시 영구히 재등록되지 않고 사라진다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func dropsRepeatingAlarmWithPastDateOnRestoreEvenThoughRepeatRuleIsNotNone() {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        let pastRepeatingAlarm = makeDiaryEntry(id: "past-daily", type: .alarm, date: Date().addingTimeInterval(-3600), repeatRule: .daily)
        diaryRepository.entriesByType = [pastRepeatingAlarm]

        sut.execute()

        #expect(notificationRepository.scheduledNotifications.isEmpty)
    }

    @Test func schedulesWithAlarmIDContentDateAndRepeatRule() throws {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        let date = Date().addingTimeInterval(3600)
        let alarm = makeDiaryEntry(id: "alarm-id", type: .alarm, date: date, content: "산책 다녀오기", repeatRule: .weekly)
        diaryRepository.entriesByType = [alarm]

        sut.execute()

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.identifier == "alarm-id")
        #expect(scheduled.body == "산책 다녀오기")
        #expect(scheduled.date == date)
        #expect(scheduled.repeatRule == .weekly)
    }

    @Test func usesAlarmTitleAsScheduleTitleWhenPresent() throws {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        let alarm = makeDiaryEntry(
            type: .alarm,
            date: Date().addingTimeInterval(3600),
            animalName: "댕댕이",
            alarmTitle: "복약 알림"
        )
        diaryRepository.entriesByType = [alarm]

        sut.execute()

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.title == "복약 알림")
    }

    @Test func fallsBackToAnimalNameAsScheduleTitleWhenAlarmTitleIsNil() throws {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        let alarm = makeDiaryEntry(
            type: .alarm,
            date: Date().addingTimeInterval(3600),
            animalName: "댕댕이",
            alarmTitle: nil
        )
        diaryRepository.entriesByType = [alarm]

        sut.execute()

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.title == "댕댕이")
    }

    @Test func schedulesEachFutureAlarmWhenMultipleExist() {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        let first = makeDiaryEntry(id: "first", type: .alarm, date: Date().addingTimeInterval(3600))
        let second = makeDiaryEntry(id: "second", type: .alarm, date: Date().addingTimeInterval(7200))
        diaryRepository.entriesByType = [first, second]

        sut.execute()

        // 프로덕션이 fetchByType 결과 순서대로 순회하므로 순서까지 고정한다.
        #expect(notificationRepository.scheduledNotifications.map(\.identifier) == ["first", "second"])
    }
}

private func makeSUT() -> (RestoreNotificationsUseCaseImpl, MockDiaryRepository, MockNotificationRepository) {
    let recorder = CallRecorder()
    let diaryRepository = MockDiaryRepository()
    diaryRepository.callRecorder = recorder
    let notificationRepository = MockNotificationRepository()
    notificationRepository.callRecorder = recorder

    let sut = RestoreNotificationsUseCaseImpl(diaryRepository: diaryRepository, notificationRepository: notificationRepository)

    return (sut, diaryRepository, notificationRepository)
}
