import Foundation
import Testing
import Domain

@testable import BanGiDa

struct RestoreBackupUseCaseTests {
    @Test func passesFileURLToRepositoryUnchanged() throws {
        let (sut, backupRepository) = makeSUT()
        let fileURL = URL(fileURLWithPath: "/var/backups/restore-target.zip")

        try sut.execute(fileURL: fileURL)

        #expect(backupRepository.requestedRestoreFileURLs == [fileURL])
    }

    @Test func propagatesErrorWhenRepositoryThrows() {
        let (sut, backupRepository) = makeSUT()
        backupRepository.restoreFromFileError = TestError.failure
        let fileURL = URL(fileURLWithPath: "/var/backups/restore-target.zip")

        #expect(throws: TestError.self) {
            try sut.execute(fileURL: fileURL)
        }
    }
}

private func makeSUT() -> (RestoreBackupUseCaseImpl, MockBackupRepository) {
    let backupRepository = MockBackupRepository()
    let sut = RestoreBackupUseCaseImpl(backupRepository: backupRepository)

    return (sut, backupRepository)
}
