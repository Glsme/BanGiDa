//
//  DocumentManager.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import UIKit
import RealmSwift
import Zip

enum DocumentError: LocalizedError {
    case createDirectoryError
    case saveImageError
    case removeDirectoryError
    case fetchImagesError
    case fetchZipFileError
    case fetchDirectoryPathError

    case compressionFailedError
    case restoreFailedError

    case fetchJsonDataError

    var errorDescription: String? {
        switch self {
        case .createDirectoryError:
            return "폴더를 생성하지 못했습니다."
        case .saveImageError:
            return "이미지를 저장하지 못했습니다."
        case .removeDirectoryError:
            return "폴더를 삭제하지 못했습니다."
        case .fetchImagesError:
            return "이미지 파일을 불러오지 못했습니다."
        case .fetchZipFileError:
            return "백업 파일을 불러오지 못했습니다."
        case .fetchDirectoryPathError:
            return "저장소 경로를 확인하지 못했습니다."
        case .compressionFailedError:
            return "백업 파일을 만들지 못했습니다."
        case .restoreFailedError:
            return "백업 파일을 복구하지 못했습니다."
        case .fetchJsonDataError:
            return "백업 데이터를 읽지 못했습니다."
        }
    }
}

enum CodableError: Error {
    case jsonDecodeError
    case jsonEncodeError
}

struct DocumentManager: DocumentManaging {
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

    func loadImageDataFromDocument(fileName: String) -> Data? {
        guard let documentDirectory = imageDirectoryPath() else { return nil }
        let fileURL = documentDirectory.appendingPathComponent(fileName)

        if FileManager.default.fileExists(atPath: fileURL.path) {
            return try? Data(contentsOf: fileURL)
        }

        return nil
    }
    
    func removeImageFromDocument(fileName: String) {
        guard let imagesDirectory = imageDirectoryPath() else { return }
        let fileURL = imagesDirectory.appendingPathComponent(fileName)

        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error)
        }
    }

    func removeAllImagesFromDocument() {
        guard let imagesDirectory = imageDirectoryPath() else { return }
        guard FileManager.default.fileExists(atPath: imagesDirectory.path) else { return }

        do {
            let contents = try FileManager.default.contentsOfDirectory(at: imagesDirectory, includingPropertiesForKeys: nil)
            for url in contents {
                try FileManager.default.removeItem(at: url)
            }
        } catch {
            print("removeAllImagesFromDocument error: \(error)")
        }
    }
    
    func saveImageDataFromDocument(fileName: String, image: Data) {
        createImagesDirectoryPath()
        
        guard let documentDirectory = imageDirectoryPath() else { return }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        do {
            try image.write(to: fileURL)
        } catch {
            print("file save Error", error)
        }
    }
    
    @discardableResult
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
    
    @discardableResult
    func createBackupFile() throws -> URL {
        var urlPaths: [URL] = []
        
        let documentPath = documentDirectoryPath()
        
        let encodedFilePath = documentPath?.appendingPathComponent("encodedData.json")
        let imagesDirectoryPath = imageDirectoryPath()
        
        createImagesDirectoryPath()
        
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
        let urlString = path.path()

        return FileManager.default.fileExists(atPath: urlString)
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
