import Foundation
import Data

@testable import BanGiDa

final class DocumentManagingStub: DocumentManaging {
    var documentDirectoryPathToReturn: URL?
    var imageDataByFileName: [String: Data] = [:]
    var createBackupFileReturnValue = URL(fileURLWithPath: "/tmp/bangida-backup.zip")
    var createBackupFileError: Error?
    var saveDataToDocumentError: Error?
    var unzipFileError: Error?

    private(set) var loadedFileNames: [String] = []
    private(set) var removedFileNames: [String] = []
    private(set) var removeAllCallCount = 0
    private(set) var createImagesDirectoryPathCallCount = 0
    private(set) var savedData: [Data] = []
    private(set) var requestedUnzipCalls: [(fileURL: URL, documentURL: URL)] = []

    func documentDirectoryPath() -> URL? {
        documentDirectoryPathToReturn
    }

    func loadImageDataFromDocument(fileName: String) -> Data? {
        loadedFileNames.append(fileName)
        return imageDataByFileName[fileName]
    }

    func removeImageFromDocument(fileName: String) {
        removedFileNames.append(fileName)
    }

    func removeAllImagesFromDocument() {
        removeAllCallCount += 1
    }

    func createImagesDirectoryPath() {
        createImagesDirectoryPathCallCount += 1
    }

    func saveDataToDocument(data: Data) throws {
        if let saveDataToDocumentError {
            throw saveDataToDocumentError
        }

        savedData.append(data)
    }

    @discardableResult
    func createBackupFile() throws -> URL {
        if let createBackupFileError {
            throw createBackupFileError
        }

        return createBackupFileReturnValue
    }

    func unzipFile(fileURL: URL, documentURL: URL) throws {
        requestedUnzipCalls.append((fileURL, documentURL))

        if let unzipFileError {
            throw unzipFileError
        }
    }
}
