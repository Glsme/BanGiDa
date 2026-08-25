//
//  RestoreBackupUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol RestoreBackupUseCase {
    func execute(fileURL: URL) throws
}

package final class RestoreBackupUseCaseImpl: RestoreBackupUseCase {
    private let backupRepository: BackupRepository

    package init(backupRepository: BackupRepository) {
        self.backupRepository = backupRepository
    }

    package func execute(fileURL: URL) throws {
        try backupRepository.restoreFromFile(fileURL)
    }
}
