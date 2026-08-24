import Foundation
import Domain

@testable import BanGiDa

final class MockBackupRepository: BackupRepository {
    var createBackupReturnValue = URL(fileURLWithPath: "/tmp/bangida-backup.zip")
    var createBackupError: Error?
    var restoreFromFileError: Error?

    private(set) var createBackupCallCount = 0
    private(set) var requestedRestoreFileURLs: [URL] = []

    func createBackup() throws -> URL {
        createBackupCallCount += 1

        if let createBackupError {
            throw createBackupError
        }

        return createBackupReturnValue
    }

    func restoreFromFile(_ fileURL: URL) throws {
        requestedRestoreFileURLs.append(fileURL)

        if let restoreFromFileError {
            throw restoreFromFileError
        }
    }
}

final class MockUserPreferencesRepository: UserPreferencesRepository {
    var preferencesToLoad = UserPreferences(isFirstLaunchCompleted: false, petName: nil, storyAgreement: false)
    var petNameToReturn: String?
    var isFirstLaunchCompletedToReturn = false
    var storyAgreementToReturn = false
    /// Diary·Alarm과 마찬가지로 저장소 간 호출 순서를 함께 검증하기 위한 공유 레코더.
    var callRecorder: CallRecorder?

    private(set) var savedPreferences: [UserPreferences] = []
    private(set) var requestedSetPetNameValues: [String] = []
    private(set) var setFirstLaunchCompletedCallCount = 0
    private(set) var requestedSetStoryAgreementValues: [Bool] = []

    func load() -> UserPreferences {
        callRecorder?.record("load")
        return preferencesToLoad
    }

    func save(_ preferences: UserPreferences) {
        callRecorder?.record("save")
        savedPreferences.append(preferences)
    }

    func getPetName() -> String? {
        petNameToReturn
    }

    func setPetName(_ name: String) {
        requestedSetPetNameValues.append(name)
    }

    func isFirstLaunchCompleted() -> Bool {
        isFirstLaunchCompletedToReturn
    }

    func setFirstLaunchCompleted() {
        setFirstLaunchCompletedCallCount += 1
    }

    func getStoryAgreement() -> Bool {
        storyAgreementToReturn
    }

    func setStoryAgreement(_ agreed: Bool) {
        requestedSetStoryAgreementValues.append(agreed)
    }
}
