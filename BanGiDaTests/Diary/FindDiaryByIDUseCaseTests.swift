import Foundation
import Testing

@testable import BanGiDa

struct FindDiaryByIDUseCaseTests {
    @Test func delegatesToFindByIDAndReturnsMatchingEntry() {
        let diaryRepository = MockDiaryRepository()
        let expectedEntry = makeDiaryEntry(id: "target-id")
        diaryRepository.entryByID = expectedEntry
        let sut = FindDiaryByIDUseCaseImpl(diaryRepository: diaryRepository)

        let result = sut.execute(id: "target-id")

        #expect(diaryRepository.requestedFindByIDValues == ["target-id"])
        #expect(result?.id == expectedEntry.id)
    }

    @Test func returnsNilWhenRepositoryFindsNoMatch() {
        let diaryRepository = MockDiaryRepository()
        diaryRepository.entryByID = nil
        let sut = FindDiaryByIDUseCaseImpl(diaryRepository: diaryRepository)

        let result = sut.execute(id: "missing-id")

        #expect(result == nil)
    }
}
