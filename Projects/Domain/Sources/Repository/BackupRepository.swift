//
//  BackupRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol BackupRepository {
    func createBackup() throws -> URL
    func restoreFromFile(_ fileURL: URL) throws
}
