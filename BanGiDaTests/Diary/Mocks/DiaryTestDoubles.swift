import Foundation
import Domain

@testable import BanGiDa

/// 서로 다른 저장소 목(mock)에 걸친 호출 순서를 검증하기 위한 공유 레코더.
/// Diary·Alarm 등 계열을 가리지 않고 같은 인스턴스를 여러 목에 주입해 쓴다.
final class CallRecorder {
    private(set) var events: [String] = []

    func record(_ event: String) {
        events.append(event)
    }
}

final class MockDiaryRepository: DiaryRepository {
    var allEntries: [DiaryEntry] = []
    var entriesByDate: [DiaryEntry] = []
    var entriesByType: [DiaryEntry] = []
    var entriesByDateAndType: [DiaryType: [DiaryEntry]] = [:]
    var entryByID: DiaryEntry?
    var saveReturnValue: DiaryEntry?
    var saveError: Error?
    var updateError: Error?
    var deleteError: Error?
    var deleteAllError: Error?
    var callRecorder: CallRecorder?

    private(set) var savedEntries: [DiaryEntry] = []
    private(set) var updatedEntries: [DiaryEntry] = []
    private(set) var deletedEntries: [DiaryEntry] = []
    private(set) var deleteAllCallCount = 0
    private(set) var requestedFetchByDateDate: Date?
    private(set) var requestedFetchByTypeType: DiaryType?
    private(set) var requestedFetchByDateAndTypeCalls: [(date: Date, type: DiaryType)] = []
    private(set) var requestedFindByIDValues: [String] = []

    func fetchAll() -> [DiaryEntry] {
        allEntries
    }

    func fetchByDate(_ date: Date) -> [DiaryEntry] {
        requestedFetchByDateDate = date
        return entriesByDate
    }

    func fetchByType(_ type: DiaryType) -> [DiaryEntry] {
        requestedFetchByTypeType = type
        return entriesByType
    }

    func fetchByDateAndType(date: Date, type: DiaryType) -> [DiaryEntry] {
        requestedFetchByDateAndTypeCalls.append((date, type))
        return entriesByDateAndType[type] ?? []
    }

    @discardableResult
    func save(_ entry: DiaryEntry) throws -> DiaryEntry {
        callRecorder?.record("save")

        if let saveError {
            throw saveError
        }

        savedEntries.append(entry)
        return saveReturnValue ?? entry
    }

    func update(_ entry: DiaryEntry) throws {
        callRecorder?.record("update")

        if let updateError {
            throw updateError
        }

        updatedEntries.append(entry)
    }

    func delete(_ entry: DiaryEntry) throws {
        callRecorder?.record("delete")

        if let deleteError {
            throw deleteError
        }

        deletedEntries.append(entry)
    }

    func deleteAll() throws {
        callRecorder?.record("deleteAll")

        if let deleteAllError {
            throw deleteAllError
        }

        deleteAllCallCount += 1
    }

    func findByID(_ id: String) -> DiaryEntry? {
        requestedFindByIDValues.append(id)
        return entryByID
    }
}

final class MockImageRepository: ImageRepository {
    var imageDataByFileName: [String: Data] = [:]
    var saveImageDataError: Error?
    var callRecorder: CallRecorder?

    private(set) var loadedFileNames: [String] = []
    private(set) var savedFileNames: [String] = []
    private(set) var savedDataByFileName: [String: Data] = [:]
    private(set) var removedFileNames: [String] = []
    private(set) var removeAllCallCount = 0

    func loadImageData(fileName: String) -> Data? {
        loadedFileNames.append(fileName)
        return imageDataByFileName[fileName]
    }

    func saveImageData(fileName: String, data: Data) throws {
        callRecorder?.record("saveImageData")

        if let saveImageDataError {
            throw saveImageDataError
        }

        savedFileNames.append(fileName)
        savedDataByFileName[fileName] = data
    }

    func removeImage(fileName: String) {
        callRecorder?.record("removeImage")
        removedFileNames.append(fileName)
    }

    func removeAll() {
        callRecorder?.record("removeAll")
        removeAllCallCount += 1
    }
}

enum TestError: Error {
    case failure
}

func makeDiaryEntry(
    id: String = "entry-id",
    type: DiaryType = .memo,
    date: Date = Date(timeIntervalSince1970: 1_000),
    registeredDate: Date = Date(timeIntervalSince1970: 500),
    animalName: String = "댕댕이",
    content: String = "내용",
    photoFileName: String? = nil,
    alarmTitle: String? = nil,
    repeatRule: AlarmRepeat = .none
) -> DiaryEntry {
    DiaryEntry(
        id: id,
        type: type,
        date: date,
        registeredDate: registeredDate,
        animalName: animalName,
        content: content,
        photoFileName: photoFileName,
        alarmTitle: alarmTitle,
        repeatRule: repeatRule
    )
}
