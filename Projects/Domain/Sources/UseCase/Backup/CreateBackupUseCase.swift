//
//  CreateBackupUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol CreateBackupUseCase {
    func execute() throws -> URL
}

package final class CreateBackupUseCaseImpl: CreateBackupUseCase {
    private let backupRepository: BackupRepository

    package init(backupRepository: BackupRepository) {
        self.backupRepository = backupRepository
    }

    package func execute() throws -> URL {
        try backupRepository.createBackup()
    }
}
