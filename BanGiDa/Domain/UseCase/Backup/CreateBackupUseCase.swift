//
//  CreateBackupUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol CreateBackupUseCase {
    func execute() throws -> URL
}

final class CreateBackupUseCaseImpl: CreateBackupUseCase {
    private let backupRepository: BackupRepository

    init(backupRepository: BackupRepository) {
        self.backupRepository = backupRepository
    }

    func execute() throws -> URL {
        try backupRepository.createBackup()
    }
}
