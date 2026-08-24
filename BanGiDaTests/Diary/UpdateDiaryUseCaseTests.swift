import Foundation
import Testing
import Domain

@testable import BanGiDa

struct UpdateDiaryUseCaseTests {
    // 캡처: photoData가 nil이면 ImageRepository를 호출하지 않고, 기존 photoFileName이
    // 그대로 유지된다. 즉 이 UseCase 경로로는 등록된 사진을 제거할 방법이 없다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func preservesExistingPhotoFileNameWhenPhotoDataIsNil() throws {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        let entry = makeDiaryEntry(photoFileName: "existing.jpg")

        try sut.execute(entry: entry, photoData: nil)

        #expect(imageRepository.savedFileNames.isEmpty)
        let updated = try #require(diaryRepository.updatedEntries.first)
        #expect(updated.photoFileName == "existing.jpg")
    }

    @Test func savesImageBeforeUpdatingEntryWhenPhotoDataIsPresent() throws {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        let entry = makeDiaryEntry(photoFileName: nil)
        let photoData = Data([0x01, 0x02])

        try sut.execute(entry: entry, photoData: photoData)

        let expectedFileName = "\(entry.id).jpg"
        #expect(imageRepository.savedFileNames == [expectedFileName])
        #expect(imageRepository.savedDataByFileName[expectedFileName] == photoData)
        #expect(diaryRepository.updatedEntries.first?.photoFileName == expectedFileName)
        #expect(diaryRepository.callRecorder?.events == ["saveImageData", "update"])
    }

    @Test func overwritesDifferentExistingPhotoFileNameWhenPhotoDataIsPresent() throws {
        let (sut, diaryRepository, _) = makeSUT()
        let entry = makeDiaryEntry(photoFileName: "old-photo.jpg")
        let photoData = Data([0x03])

        try sut.execute(entry: entry, photoData: photoData)

        let expectedFileName = "\(entry.id).jpg"
        #expect(diaryRepository.updatedEntries.first?.photoFileName == expectedFileName)
    }

    // 캡처: saveImageData가 성공한 뒤 update가 throw하면, 이미 쓰인 이미지 파일이
    // 정리되지 않고 고아 파일로 남는다. SaveDiaryUseCase와 같은 패턴이다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func leavesOrphanedImageFileWhenUpdateThrowsAfterImageWasSaved() {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        diaryRepository.updateError = TestError.failure
        let entry = makeDiaryEntry(photoFileName: nil)

        #expect(throws: TestError.self) {
            try sut.execute(entry: entry, photoData: Data([0x01]))
        }

        #expect(imageRepository.savedFileNames == ["\(entry.id).jpg"])
        #expect(imageRepository.removedFileNames.isEmpty)
        #expect(diaryRepository.updatedEntries.isEmpty)
    }

    @Test func doesNotCallUpdateWhenSaveImageDataThrows() {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        imageRepository.saveImageDataError = TestError.failure
        let entry = makeDiaryEntry(photoFileName: nil)

        #expect(throws: TestError.self) {
            try sut.execute(entry: entry, photoData: Data([0x01]))
        }

        #expect(diaryRepository.updatedEntries.isEmpty)
    }
}

private func makeSUT() -> (UpdateDiaryUseCaseImpl, MockDiaryRepository, MockImageRepository) {
    let recorder = CallRecorder()
    let diaryRepository = MockDiaryRepository()
    diaryRepository.callRecorder = recorder
    let imageRepository = MockImageRepository()
    imageRepository.callRecorder = recorder

    let sut = UpdateDiaryUseCaseImpl(diaryRepository: diaryRepository, imageRepository: imageRepository)

    return (sut, diaryRepository, imageRepository)
}
