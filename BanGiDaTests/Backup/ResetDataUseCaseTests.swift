import Foundation
import Testing

@testable import BanGiDa

struct ResetDataUseCaseTests {
    @Test func callsAllSixRepositoryMethodsInOrderOnHappyPath() throws {
        let (sut, _, _, userPreferencesRepository, _) = makeSUT()

        try sut.execute()

        #expect(userPreferencesRepository.callRecorder?.events == [
            "load", "save", "deleteAll", "removeAll", "removeAllPending", "removeAllDelivered"
        ])
    }

    @Test func savesPreferencesWithFirstLaunchResetAndPetNameCleared() throws {
        let (sut, _, _, userPreferencesRepository, _) = makeSUT()
        userPreferencesRepository.preferencesToLoad = UserPreferences(
            isFirstLaunchCompleted: true,
            petName: "댕댕이",
            storyAgreement: false
        )

        try sut.execute()

        let saved = try #require(userPreferencesRepository.savedPreferences.first)
        #expect(saved.isFirstLaunchCompleted == false)
        #expect(saved.petName == nil)
    }

    // 캡처: storyAgreement는 초기화 대상이 아니다. load()가 돌려준 값이 가공 없이 그대로 다시 save된다.
    @Test func preservesStoryAgreementValueFromLoadRatherThanResettingIt() throws {
        let (sut, _, _, userPreferencesRepository, _) = makeSUT()
        userPreferencesRepository.preferencesToLoad = UserPreferences(
            isFirstLaunchCompleted: true,
            petName: "댕댕이",
            storyAgreement: true
        )

        try sut.execute()

        let saved = try #require(userPreferencesRepository.savedPreferences.first)
        #expect(saved.storyAgreement == true)
    }

    @Test func propagatesErrorWhenDeleteAllThrows() {
        let (sut, diaryRepository, _, _, _) = makeSUT()
        diaryRepository.deleteAllError = TestError.failure

        #expect(throws: TestError.self) {
            try sut.execute()
        }
    }

    // 캡처(최우선 항목, 고치지 말 것): userPreferencesRepository.save(prefs)가
    // diaryRepository.deleteAll()보다 먼저 일어난다. deleteAll()이 throw하면
    // 설정("첫 실행 상태 + 펫 이름 없음")은 이미 커밋된 채로 남고, 일기 데이터는
    // 그대로 남으며, 이미지 정리·알림 정리(pending/delivered)도 전부 건너뛴다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func commitsPreferencesResetBeforeDeleteAllAndSkipsLaterStepsWhenDeleteAllThrows() throws {
        let (sut, diaryRepository, notificationRepository, userPreferencesRepository, imageRepository) = makeSUT()
        diaryRepository.deleteAllError = TestError.failure

        #expect(throws: TestError.self) {
            try sut.execute()
        }

        // 설정 초기화(save)는 deleteAll 실패와 무관하게 이미 커밋됐다.
        let saved = try #require(userPreferencesRepository.savedPreferences.first)
        #expect(saved.isFirstLaunchCompleted == false)
        #expect(saved.petName == nil)

        // deleteAll까지는 도달했고 그 뒤 단계는 전부 건너뛴다.
        #expect(userPreferencesRepository.callRecorder?.events == ["load", "save", "deleteAll"])
        #expect(imageRepository.removeAllCallCount == 0)
        #expect(notificationRepository.removeAllPendingCallCount == 0)
        #expect(notificationRepository.removeAllDeliveredCallCount == 0)
    }
}

private func makeSUT() -> (
    ResetDataUseCaseImpl,
    MockDiaryRepository,
    MockNotificationRepository,
    MockUserPreferencesRepository,
    MockImageRepository
) {
    let recorder = CallRecorder()
    let diaryRepository = MockDiaryRepository()
    diaryRepository.callRecorder = recorder
    let notificationRepository = MockNotificationRepository()
    notificationRepository.callRecorder = recorder
    let userPreferencesRepository = MockUserPreferencesRepository()
    userPreferencesRepository.callRecorder = recorder
    let imageRepository = MockImageRepository()
    imageRepository.callRecorder = recorder

    let sut = ResetDataUseCaseImpl(
        diaryRepository: diaryRepository,
        notificationRepository: notificationRepository,
        userPreferencesRepository: userPreferencesRepository,
        imageRepository: imageRepository
    )

    return (sut, diaryRepository, notificationRepository, userPreferencesRepository, imageRepository)
}
