//
//  BackupRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import RealmSwift

final class BackupRepositoryImpl: BackupRepository {
    private let documentManager: DocumentManager
    private let imageRepository: ImageRepository

    init(documentManager: DocumentManager = DocumentManager(), imageRepository: ImageRepository) {
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

        // Copy file if needed
        if !FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            try FileManager.default.copyItem(at: fileURL, to: sandboxFileURL)
        }

        // 기존 이미지를 비워 백업과 무관한 orphan 파일이 남지 않도록 한다.
        imageRepository.removeAll()

        // Unzip
        let zipFileURL = path.appendingPathComponent(fileURL.lastPathComponent)
        try documentManager.unzipFile(fileURL: zipFileURL, documentURL: path)

        // Decode and restore Realm
        let dataPath = path.appendingPathComponent("encodedData.json")
        let jsonData = try Data(contentsOf: dataPath)

        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        let decodedData = try decoder.decode([Diary].self, from: jsonData)

        try realm.write {
            realm.deleteAll()
            realm.add(decodedData)
        }

        // Re-create backup file (same as original code's behavior)
        _ = try documentManager.createBackupFile()
    }
}
