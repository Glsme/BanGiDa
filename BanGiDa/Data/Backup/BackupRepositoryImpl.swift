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
    private let realm: Realm

    init(documentManager: DocumentManager = DocumentManager(), realm: Realm = try! Realm()) {
        self.documentManager = documentManager
        self.realm = realm
    }

    func createBackup() throws -> URL {
        // Encode current diary data to JSON
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
        guard let path = documentManager.documentDirectoryPath() else {
            throw DocumentError.fetchDirectoryPathError
        }

        let sandboxFileURL = path.appendingPathComponent(fileURL.lastPathComponent)

        // Copy file if needed
        if !FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            try FileManager.default.copyItem(at: fileURL, to: sandboxFileURL)
        }

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
