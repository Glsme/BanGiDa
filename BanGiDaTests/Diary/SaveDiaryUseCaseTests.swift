import Foundation
import Testing

@testable import BanGiDa

struct SaveDiaryUseCaseTests {
    @Test func doesNotTouchImageRepositoryWhenPhotoDataIsNil() throws {
        let (sut, diaryRepository, imageRepository) = makeSUT()

        let result = try sut.execute(
            type: .memo,
            date: Date(timeIntervalSince1970: 1_000),
            content: "내용",
            animalName: "댕댕이",
            photoData: nil,
            alarmTitle: nil,
            repeatRule: .none
        )

        #expect(imageRepository.savedFileNames.isEmpty)
        #expect(result.photoFileName == nil)
        #expect(diaryRepository.savedEntries.first?.photoFileName == nil)
    }

    @Test func savesImageBeforePersistingEntryWhenPhotoDataIsPresent() throws {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        let photoData = Data([0x01, 0x02])

        let result = try sut.execute(
            type: .memo,
            date: Date(timeIntervalSince1970: 1_000),
            content: "내용",
            animalName: "댕댕이",
            photoData: photoData,
            alarmTitle: nil,
            repeatRule: .none
        )

        let expectedFileName = "\(result.id).jpg"
        #expect(imageRepository.savedFileNames == [expectedFileName])
        #expect(imageRepository.savedDataByFileName[expectedFileName] == photoData)
        #expect(result.photoFileName == expectedFileName)
        #expect(diaryRepository.savedEntries.first?.photoFileName == expectedFileName)
        #expect(diaryRepository.callRecorder?.events == ["saveImageData", "save"])
    }

    @Test func passesArgumentsThroughToSavedEntryUnchanged() throws {
        let (sut, diaryRepository, _) = makeSUT()
        let date = Date(timeIntervalSince1970: 12_345)

        _ = try sut.execute(
            type: .hospital,
            date: date,
            content: "병원 다녀옴",
            animalName: "냥냥이",
            photoData: nil,
            alarmTitle: "복약 알림",
            repeatRule: .weekly
        )

        let saved = try #require(diaryRepository.savedEntries.first)
        #expect(saved.type == .hospital)
        #expect(saved.date == date)
        #expect(saved.animalName == "냥냥이")
        #expect(saved.content == "병원 다녀옴")
        #expect(saved.alarmTitle == "복약 알림")
        #expect(saved.repeatRule == .weekly)
    }

    @Test func generatesNewUUIDStringAsID() throws {
        let (sut, diaryRepository, _) = makeSUT()

        _ = try sut.execute(
            type: .memo,
            date: Date(),
            content: "내용",
            animalName: "댕댕이",
            photoData: nil,
            alarmTitle: nil,
            repeatRule: .none
        )

        let saved = try #require(diaryRepository.savedEntries.first)
        #expect(UUID(uuidString: saved.id) != nil)
    }

    @Test func fillsRegisteredDateWithExecutionTime() throws {
        let (sut, diaryRepository, _) = makeSUT()
        let before = Date()

        _ = try sut.execute(
            type: .memo,
            date: Date(timeIntervalSince1970: 1_000),
            content: "내용",
            animalName: "댕댕이",
            photoData: nil,
            alarmTitle: nil,
            repeatRule: .none
        )

        let after = Date()
        let saved = try #require(diaryRepository.savedEntries.first)
        #expect(saved.registeredDate >= before)
        #expect(saved.registeredDate <= after)
    }

    // 반환값의 출처를 고정한다. UseCase는 지역에서 조립한 entry가 아니라
    // diaryRepository.save가 돌려준 값을 그대로 반환한다.
    // 저장소가 id를 재발급하는 구현으로 바뀌어도 호출부가 그 값을 받도록 보장하는 지점이다.
    @Test func returnsRepositorySaveResultRatherThanLocallyBuiltEntry() throws {
        let (sut, diaryRepository, _) = makeSUT()
        diaryRepository.saveReturnValue = makeDiaryEntry(
            id: "repository-assigned-id",
            content: "저장소가 돌려준 값"
        )

        let result = try sut.execute(
            type: .memo,
            date: Date(timeIntervalSince1970: 1_000),
            content: "내용",
            animalName: "댕댕이",
            photoData: nil,
            alarmTitle: nil,
            repeatRule: .none
        )

        #expect(result.id == "repository-assigned-id")
        #expect(result.content == "저장소가 돌려준 값")
        #expect(diaryRepository.savedEntries.first?.id != result.id)
    }

    // 캡처: saveImageData는 성공했지만 diaryRepository.save가 실패하면
    // 이미 저장된 이미지 파일이 정리되지 않고 고아 파일로 남는다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func leavesOrphanedImageFileWhenSaveThrowsAfterImageWasSaved() {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        diaryRepository.saveError = TestError.failure

        #expect(throws: TestError.self) {
            try sut.execute(
                type: .memo,
                date: Date(timeIntervalSince1970: 1_000),
                content: "내용",
                animalName: "댕댕이",
                photoData: Data([0x01]),
                alarmTitle: nil,
                repeatRule: .none
            )
        }

        #expect(imageRepository.savedFileNames.count == 1)
        #expect(imageRepository.removedFileNames.isEmpty)
        #expect(diaryRepository.savedEntries.isEmpty)
    }
}

private func makeSUT() -> (SaveDiaryUseCaseImpl, MockDiaryRepository, MockImageRepository) {
    let recorder = CallRecorder()
    let diaryRepository = MockDiaryRepository()
    diaryRepository.callRecorder = recorder
    let imageRepository = MockImageRepository()
    imageRepository.callRecorder = recorder

    let sut = SaveDiaryUseCaseImpl(diaryRepository: diaryRepository, imageRepository: imageRepository)

    return (sut, diaryRepository, imageRepository)
}
