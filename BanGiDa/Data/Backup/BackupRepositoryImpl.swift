//
//  BackupRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import RealmSwift
import Domain

final class BackupRepositoryImpl: BackupRepository {
    private let documentManager: DocumentManaging
    private let imageRepository: ImageRepository

    init(documentManager: DocumentManaging = DocumentManager(), imageRepository: ImageRepository) {
        self.documentManager = documentManager
        self.imageRepository = imageRepository
    }

    private func makeRealm() throws -> Realm {
        try Realm()
    }

    func createBackup() throws -> URL {
        let realm = try makeRealm()
        let diaryList = realm.objects(Diary.self).sorted(byKeyPath: "regDate", ascending: false)
        let encoder = JSONEncoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        let encodedData = try encoder.encode(Array(diaryList))

        // Save JSON to document
        try documentManager.saveDataToDocument(data: encodedData)

        // Create zip backup
        let backupFilePath = try documentManager.createBackupFile()
        return backupFilePath
    }

    func restoreFromFile(_ fileURL: URL) throws {
        let realm = try makeRealm()
        guard let path = documentManager.documentDirectoryPath() else {
            throw DocumentError.fetchDirectoryPathError
        }

        let sandboxFileURL = path.appendingPathComponent(fileURL.lastPathComponent)

        // Copy file into sandbox if needed
        if !FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            try FileManager.default.copyItem(at: fileURL, to: sandboxFileURL)
        }

        // --- Phase 1: verification (no destructive operations yet) ---

        // Unzip into a staging directory so the live images directory is untouched
        // until we know the archive is valid.
        let stagingURL = path.appendingPathComponent("restore_staging_\(UUID().uuidString)")
        defer {
            try? FileManager.default.removeItem(at: stagingURL)
        }
        try FileManager.default.createDirectory(at: stagingURL, withIntermediateDirectories: true, attributes: nil)

        let zipFileURL = path.appendingPathComponent(fileURL.lastPathComponent)
        try documentManager.unzipFile(fileURL: zipFileURL, documentURL: stagingURL)

        // Decode JSON from the staging directory — throws before touching live data if invalid
        let stagingDataPath = stagingURL.appendingPathComponent("encodedData.json")
        let jsonData = try Data(contentsOf: stagingDataPath)

        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decodedData = try decoder.decode([Diary].self, from: jsonData)

        // --- Phase 2: destructive operations (archive is known-good) ---

        // Remove existing images
        imageRepository.removeAll()

        // Move extracted images from staging into the live images directory
        let stagingImagesURL = stagingURL.appendingPathComponent("images")
        let liveImagesURL = path.appendingPathComponent("images")
        if FileManager.default.fileExists(atPath: stagingImagesURL.path) {
            if !FileManager.default.fileExists(atPath: liveImagesURL.path) {
                try FileManager.default.createDirectory(at: liveImagesURL, withIntermediateDirectories: true, attributes: nil)
            }
            let stagedFiles = try FileManager.default.contentsOfDirectory(at: stagingImagesURL, includingPropertiesForKeys: nil)
            for stagedFile in stagedFiles {
                let destination = liveImagesURL.appendingPathComponent(stagedFile.lastPathComponent)
                if FileManager.default.fileExists(atPath: destination.path) {
                    try FileManager.default.removeItem(at: destination)
                }
                try FileManager.default.moveItem(at: stagedFile, to: destination)
            }
        }

        // Overwrite Realm with decoded data
        try realm.write {
            realm.deleteAll()
            realm.add(decodedData)
        }
    }
}
