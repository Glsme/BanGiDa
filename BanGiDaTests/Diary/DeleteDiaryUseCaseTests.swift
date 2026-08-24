import Foundation
import Testing

@testable import BanGiDa

struct DeleteDiaryUseCaseTests {
    @Test func removesImageBeforeDeletingEntryWhenPhotoFileNameExists() throws {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        let entry = makeDiaryEntry(photoFileName: "photo.jpg")

        try sut.execute(entry: entry)

        #expect(imageRepository.removedFileNames == ["photo.jpg"])
        #expect(diaryRepository.deletedEntries.count == 1)
        #expect(diaryRepository.callRecorder?.events == ["removeImage", "delete"])
    }

    @Test func doesNotRemoveImageWhenPhotoFileNameIsNil() throws {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        let entry = makeDiaryEntry(photoFileName: nil)

        try sut.execute(entry: entry)

        #expect(imageRepository.removedFileNames.isEmpty)
        #expect(diaryRepository.deletedEntries.count == 1)
        #expect(diaryRepository.callRecorder?.events == ["delete"])
    }

    // 캡처: removeImage 이후 delete가 실패하면 이미지 파일은 이미 삭제된 채
    // 엔트리는 저장소에 그대로 남아 불일치 상태가 된다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func leavesEntryPersistedWhenDeleteThrowsAfterImageWasRemoved() {
        let (sut, diaryRepository, imageRepository) = makeSUT()
        diaryRepository.deleteError = TestError.failure
        let entry = makeDiaryEntry(photoFileName: "photo.jpg")

        #expect(throws: TestError.self) {
            try sut.execute(entry: entry)
        }

        #expect(imageRepository.removedFileNames == ["photo.jpg"])
        #expect(diaryRepository.deletedEntries.isEmpty)
    }
}

private func makeSUT() -> (DeleteDiaryUseCaseImpl, MockDiaryRepository, MockImageRepository) {
    let recorder = CallRecorder()
    let diaryRepository = MockDiaryRepository()
    diaryRepository.callRecorder = recorder
    let imageRepository = MockImageRepository()
    imageRepository.callRecorder = recorder

    let sut = DeleteDiaryUseCaseImpl(diaryRepository: diaryRepository, imageRepository: imageRepository)

    return (sut, diaryRepository, imageRepository)
}
