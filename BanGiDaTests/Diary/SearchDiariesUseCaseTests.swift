import Foundation
import Testing
import Domain

@testable import BanGiDa

struct SearchDiariesUseCaseTests {
    @Test func executeDelegatesToFetchByTypeWithoutTransformingResult() {
        let diaryRepository = MockDiaryRepository()
        let expectedEntries = [makeDiaryEntry(id: "a"), makeDiaryEntry(id: "b")]
        diaryRepository.entriesByType = expectedEntries
        let sut = SearchDiariesUseCaseImpl(diaryRepository: diaryRepository)

        let result = sut.execute(type: .hospital)

        #expect(diaryRepository.requestedFetchByTypeType == .hospital)
        #expect(result.map(\.id) == expectedEntries.map(\.id))
    }

    @Test func executeAllDelegatesToFetchAllWithoutTransformingResult() {
        let diaryRepository = MockDiaryRepository()
        let expectedEntries = [makeDiaryEntry(id: "a"), makeDiaryEntry(id: "b"), makeDiaryEntry(id: "c")]
        diaryRepository.allEntries = expectedEntries
        let sut = SearchDiariesUseCaseImpl(diaryRepository: diaryRepository)

        let result = sut.executeAll()

        #expect(result.map(\.id) == expectedEntries.map(\.id))
    }
}
