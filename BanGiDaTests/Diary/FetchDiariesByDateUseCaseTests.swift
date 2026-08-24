import Foundation
import Testing
import Domain

@testable import BanGiDa

struct FetchDiariesByDateUseCaseTests {
    // UseCase가 순회하는 대상은 DiaryType.allCases가 아니라 소스에 박힌 리터럴 배열이다.
    // 특성화 테스트이므로 allCases가 아니라 그 리터럴을 순서까지 그대로 고정한다.
    @Test func queriesHardcodedSixDiaryTypesInFixedOrderForGivenDate() {
        let diaryRepository = MockDiaryRepository()
        let sut = FetchDiariesByDateUseCaseImpl(diaryRepository: diaryRepository)
        let date = Date(timeIntervalSince1970: 1_000)

        _ = sut.execute(date: date)

        let queriedTypes = diaryRepository.requestedFetchByDateAndTypeCalls.map(\.type)
        #expect(queriedTypes == [.memo, .alarm, .hospital, .shower, .pill, .abnormal])
        #expect(diaryRepository.requestedFetchByDateAndTypeCalls.allSatisfy { $0.date == date })
    }

    // 감시용 테스트: 현재는 하드코딩 목록이 DiaryType 전체와 우연히 일치한다.
    // DiaryType에 케이스가 추가되면 이 테스트가 깨지면서
    // "UseCase가 새 타입을 조회하지 않는다"는 사실을 드러낸다.
    // 자세한 내용은 CHARACTERIZATION-NOTES.md 참고.
    @Test func hardcodedTypeListCurrentlyCoversEveryDiaryTypeCase() {
        let diaryRepository = MockDiaryRepository()
        let sut = FetchDiariesByDateUseCaseImpl(diaryRepository: diaryRepository)

        _ = sut.execute(date: Date(timeIntervalSince1970: 1_000))

        let queriedTypes = diaryRepository.requestedFetchByDateAndTypeCalls.map(\.type)
        #expect(Set(queriedTypes) == Set(DiaryType.allCases))
    }

    @Test func omitsTypesWithNoEntriesFromResultDictionary() throws {
        let diaryRepository = MockDiaryRepository()
        let memoEntry = makeDiaryEntry(id: "memo-1", type: .memo)
        diaryRepository.entriesByDateAndType = [
            .memo: [memoEntry],
            .alarm: []
        ]
        let sut = FetchDiariesByDateUseCaseImpl(diaryRepository: diaryRepository)

        let result = sut.execute(date: Date(timeIntervalSince1970: 1_000))

        #expect(result.keys.contains(.memo))
        #expect(result.keys.contains(.alarm) == false)
        let memoEntries = try #require(result[.memo])
        #expect(memoEntries.map(\.id) == ["memo-1"])
    }

    @Test func returnsEmptyDictionaryWhenAllTypesAreEmpty() {
        let diaryRepository = MockDiaryRepository()
        let sut = FetchDiariesByDateUseCaseImpl(diaryRepository: diaryRepository)

        let result = sut.execute(date: Date(timeIntervalSince1970: 1_000))

        #expect(result.isEmpty)
    }

    @Test func executeFlatDelegatesToFetchByDateWithoutTransformingResult() {
        let diaryRepository = MockDiaryRepository()
        let expectedEntries = [makeDiaryEntry(id: "a", type: .memo), makeDiaryEntry(id: "b", type: .alarm)]
        diaryRepository.entriesByDate = expectedEntries
        let sut = FetchDiariesByDateUseCaseImpl(diaryRepository: diaryRepository)
        let date = Date(timeIntervalSince1970: 2_000)

        let result = sut.executeFlat(date: date)

        #expect(diaryRepository.requestedFetchByDateDate == date)
        #expect(result.map(\.id) == expectedEntries.map(\.id))
    }
}
