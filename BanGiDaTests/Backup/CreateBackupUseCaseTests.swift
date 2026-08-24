import Foundation
import Testing

@testable import BanGiDa

struct CreateBackupUseCaseTests {
    @Test func returnsURLFromRepositoryUnchanged() throws {
        let (sut, backupRepository) = makeSUT()
        let expectedURL = URL(fileURLWithPath: "/var/backups/bangida-backup.zip")
        backupRepository.createBackupReturnValue = expectedURL

        let result = try sut.execute()

        #expect(result == expectedURL)
    }

    @Test func delegatesToRepositoryCreateBackup() throws {
        let (sut, backupRepository) = makeSUT()

        _ = try sut.execute()

        #expect(backupRepository.createBackupCallCount == 1)
    }

    @Test func propagatesErrorWhenRepositoryThrows() {
        let (sut, backupRepository) = makeSUT()
        backupRepository.createBackupError = TestError.failure

        #expect(throws: TestError.self) {
            try sut.execute()
        }
    }
}

private func makeSUT() -> (CreateBackupUseCaseImpl, MockBackupRepository) {
    let backupRepository = MockBackupRepository()
    let sut = CreateBackupUseCaseImpl(backupRepository: backupRepository)

    return (sut, backupRepository)
}
