//
//  RestoreBackupUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol RestoreBackupUseCase {
    func execute(fileURL: URL) throws
}

final class RestoreBackupUseCaseImpl: RestoreBackupUseCase {
    private let backupRepository: BackupRepository

    init(backupRepository: BackupRepository) {
        self.backupRepository = backupRepository
    }

    func execute(fileURL: URL) throws {
        try backupRepository.restoreFromFile(fileURL)
    }
}
