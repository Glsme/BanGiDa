//
//  DocumentManager.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import UIKit
import RealmSwift
import Zip

enum DocumentError: Error {
    case createDirectoryError
    case saveImageError
    case removeDirectoryError
    case fetchImagesError
    case fetchZipFileError
    case fetchDirectoryPathError
    
    case compressionFailedError
    case restoreFailedError
    
    case fetchJsonDataError
}

enum CodableError: Error {
    case jsonDecodeError
    case jsonEncodeError
}

struct DocumentManager {
    func documentDirectoryPath() -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentDirectory
    }
    
    func loadImageFromDocument(fileName: String) -> UIImage? {
        guard let documentDirectory = imageDirectoryPath() else { return UIImage(named: "BasicDog") }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return UIImage(named: "BasicDog")
        }
    }
    
    func removeImageFromDocument(fileName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent(fileName) // 세부 경로. 이미지를 저장할 위치
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error)
        }
    }
    
    func saveImageFromDocument(fileName: String, image: UIImage) {
        createImagesDirectoryPath()
        
        guard let documentDirectory = imageDirectoryPath() else { return }
        
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("file save Error", error)
        }
    }
    
    func fetchDocumentZipFile() throws -> [URL] {
        do {
            guard let path = documentDirectoryPath() else { return [] }
            
            let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            
            let zip = docs.filter { $0.pathExtension == "zip" }
            
            return zip
            
        } catch {
            throw DocumentError.fetchZipFileError
        }
        
    }
    
    func saveDataToDocument(data: Data) throws {
        guard let documentPath = documentDirectoryPath() else { throw DocumentError.fetchDirectoryPathError }
        
        let jsonDataPath = documentPath.appendingPathComponent("encodedData.json")

        try data.write(to: jsonDataPath)
    }
    
    func createBackupFile() throws -> URL {
        var urlPaths: [URL] = []
        
        let documentPath = documentDirectoryPath()
        
        let encodedFilePath = documentPath?.appendingPathComponent("encodedData.json")
        let imagesDirectoryPath = imageDirectoryPath()
        
        guard let realmFilePath = encodedFilePath, let imagesDirectoryPath = imagesDirectoryPath else {
            throw DocumentError.fetchDirectoryPathError
        }
        
        guard isFileExist(path: realmFilePath) && isFileExist(path: imagesDirectoryPath) else {
            throw DocumentError.compressionFailedError
        }
        
        urlPaths.append(contentsOf: [realmFilePath, imagesDirectoryPath])
        
        do {
            let zipFilePath = try Zip.quickZipFiles(urlPaths, fileName: "BangiDa\(Date().backupFileTitle)")
            
            return zipFilePath
        }
        catch {
            throw DocumentError.compressionFailedError
        }
    }
    
    private func imageDirectoryPath() -> URL? {
        guard let documentPath = documentDirectoryPath() else { return nil }
        let imagesDirectoryPath = documentPath.appendingPathComponent("images")
        
        return imagesDirectoryPath
    }
    
    private func isFileExist(path: URL) -> Bool {
        var urlString: String?
        
        if #available(iOS 16, *) {
            urlString = path.path()
        } else {
            urlString = path.path
        }
        
        return FileManager.default.fileExists(atPath: urlString ?? "")
    }
    
    func createImagesDirectoryPath() {
        guard let documentPath = documentDirectoryPath() else { return }
        let imagesFilePath = documentPath.appendingPathComponent("images")
        
        if !FileManager.default.fileExists(atPath: imagesFilePath.path) {
            do {
                try FileManager.default.createDirectory(atPath: imagesFilePath.path, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("image 폴더는 이미 있단다")
            }
        }
    }
    
    func unzipFile(fileURL: URL, documentURL: URL) throws {
        do {
            try Zip.unzipFile(fileURL, destination: documentURL, overwrite: true, password: nil, progress: { progress in
                print(progress)
            }, fileOutputHandler: { unzippedFile in
                print("복구 완료")
            })
        } catch {
            throw DocumentError.restoreFailedError
        }
    }
}
