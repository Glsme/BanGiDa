import Foundation
import Testing
import Domain

@testable import BanGiDa

struct SaveAlarmUseCaseTests {
    @Test func createsAlarmTypeEntryWithNilPhotoFileName() throws {
        let (sut, diaryRepository, _) = makeSUT()

        _ = try sut.execute(
            date: Date().addingTimeInterval(3600),
            content: "약 먹이기",
            animalName: "댕댕이",
            alarmTitle: "복약 알림",
            repeatRule: .none
        )

        let saved = try #require(diaryRepository.savedEntries.first)
        #expect(saved.type == .alarm)
        #expect(saved.photoFileName == nil)
    }

    @Test func generatesNewUUIDStringAsID() throws {
        let (sut, diaryRepository, _) = makeSUT()

        _ = try sut.execute(
            date: Date().addingTimeInterval(3600),
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .none
        )

        let saved = try #require(diaryRepository.savedEntries.first)
        #expect(UUID(uuidString: saved.id) != nil)
    }

    @Test func fillsRegisteredDateWithExecutionTime() throws {
        let (sut, diaryRepository, _) = makeSUT()
        let before = Date()

        _ = try sut.execute(
            date: Date().addingTimeInterval(3600),
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .none
        )

        let after = Date()
        let saved = try #require(diaryRepository.savedEntries.first)
        #expect(saved.registeredDate >= before)
        #expect(saved.registeredDate <= after)
    }

    @Test func passesArgumentsThroughToSavedEntryUnchanged() throws {
        let (sut, diaryRepository, _) = makeSUT()
        let date = Date().addingTimeInterval(3600)

        _ = try sut.execute(
            date: date,
            content: "산책 다녀오기",
            animalName: "냥냥이",
            alarmTitle: "산책 알림",
            repeatRule: .weekly
        )

        let saved = try #require(diaryRepository.savedEntries.first)
        #expect(saved.date == date)
        #expect(saved.content == "산책 다녀오기")
        #expect(saved.animalName == "냥냥이")
        #expect(saved.alarmTitle == "산책 알림")
        #expect(saved.repeatRule == .weekly)
    }

    @Test func schedulesWhenDateIsInFutureAndRepeatRuleIsNone() throws {
        let (sut, _, notificationRepository) = makeSUT()

        _ = try sut.execute(
            date: Date().addingTimeInterval(3600),
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .none
        )

        #expect(notificationRepository.scheduledNotifications.count == 1)
    }

    @Test func doesNotScheduleWhenDateIsInPastAndRepeatRuleIsNone() throws {
        let (sut, _, notificationRepository) = makeSUT()

        _ = try sut.execute(
            date: Date().addingTimeInterval(-3600),
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .none
        )

        #expect(notificationRepository.scheduledNotifications.isEmpty)
    }

    @Test func schedulesWhenDateIsInPastButRepeatRuleIsNotNone() throws {
        let (sut, _, notificationRepository) = makeSUT()

        _ = try sut.execute(
            date: Date().addingTimeInterval(-3600),
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .daily
        )

        #expect(notificationRepository.scheduledNotifications.count == 1)
    }

    // 캡처: schedule에 넘기는 identifier는 로컬에서 조립한 entry.id가 아니라
    // diaryRepository.save가 돌려준 entry의 id다. 저장소가 id를 재발급해도
    // 알림 식별자가 그 값을 따라가도록 보장하는 지점이다.
    @Test func usesRepositoryReturnedIDAsScheduleIdentifierRatherThanLocallyGeneratedID() throws {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        diaryRepository.saveReturnValue = makeDiaryEntry(id: "repository-assigned-id", type: .alarm)

        _ = try sut.execute(
            date: Date().addingTimeInterval(3600),
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .none
        )

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.identifier == "repository-assigned-id")
        #expect(scheduled.identifier != diaryRepository.savedEntries.first?.id)
    }

    // 캡처: schedule에 넘기는 date/repeatRule은 저장소가 돌려준 entry의 값이 아니라
    // execute의 인자다. identifier만 저장소 반환값을 따르는 비대칭 구조다.
    @Test func schedulesWithArgumentDateAndRepeatRuleRatherThanRepositoryReturnedEntryValues() throws {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        let argumentDate = Date().addingTimeInterval(3600)
        diaryRepository.saveReturnValue = makeDiaryEntry(
            id: "repository-assigned-id",
            type: .alarm,
            date: Date().addingTimeInterval(7200),
            repeatRule: .monthly
        )

        _ = try sut.execute(
            date: argumentDate,
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .weekly
        )

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.identifier == "repository-assigned-id")
        #expect(scheduled.date == argumentDate)
        #expect(scheduled.repeatRule == .weekly)
    }

    // 캡처: 반환값도 지역에서 조립한 entry가 아니라 diaryRepository.save가 돌려준 값이다.
    @Test func returnsRepositorySaveResultRatherThanLocallyBuiltEntry() throws {
        let (sut, diaryRepository, _) = makeSUT()
        diaryRepository.saveReturnValue = makeDiaryEntry(
            id: "repository-assigned-id",
            type: .alarm,
            content: "저장소가 돌려준 값"
        )

        let result = try sut.execute(
            date: Date().addingTimeInterval(3600),
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .none
        )

        #expect(result.id == "repository-assigned-id")
        #expect(result.content == "저장소가 돌려준 값")
        #expect(diaryRepository.savedEntries.first?.id != result.id)
    }

    @Test func schedulesWithAlarmTitleAsTitleAndContentAsBody() throws {
        let (sut, _, notificationRepository) = makeSUT()

        _ = try sut.execute(
            date: Date().addingTimeInterval(3600),
            content: "약 먹이기",
            animalName: "댕댕이",
            alarmTitle: "복약 알림",
            repeatRule: .none
        )

        let scheduled = try #require(notificationRepository.scheduledNotifications.first)
        #expect(scheduled.title == "복약 알림")
        #expect(scheduled.body == "약 먹이기")
    }

    @Test func doesNotScheduleWhenSaveThrows() {
        let (sut, diaryRepository, notificationRepository) = makeSUT()
        diaryRepository.saveError = TestError.failure

        #expect(throws: TestError.self) {
            try sut.execute(
                date: Date().addingTimeInterval(3600),
                content: "내용",
                animalName: "댕댕이",
                alarmTitle: "알림",
                repeatRule: .none
            )
        }

        #expect(notificationRepository.scheduledNotifications.isEmpty)
    }

    @Test func callsSaveBeforeSchedule() throws {
        let (sut, diaryRepository, _) = makeSUT()

        _ = try sut.execute(
            date: Date().addingTimeInterval(3600),
            content: "내용",
            animalName: "댕댕이",
            alarmTitle: "알림",
            repeatRule: .none
        )

        #expect(diaryRepository.callRecorder?.events == ["save", "schedule"])
    }
}

private func makeSUT() -> (SaveAlarmUseCaseImpl, MockDiaryRepository, MockNotificationRepository) {
    let recorder = CallRecorder()
    let diaryRepository = MockDiaryRepository()
    diaryRepository.callRecorder = recorder
    let notificationRepository = MockNotificationRepository()
    notificationRepository.callRecorder = recorder

    let sut = SaveAlarmUseCaseImpl(diaryRepository: diaryRepository, notificationRepository: notificationRepository)

    return (sut, diaryRepository, notificationRepository)
}
