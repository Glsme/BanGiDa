//
//  DocumentManaging.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol DocumentManaging {
    func documentDirectoryPath() -> URL?

    func loadImageDataFromDocument(fileName: String) -> Data?
    func removeImageFromDocument(fileName: String)
    func removeAllImagesFromDocument()
    func createImagesDirectoryPath()

    func saveDataToDocument(data: Data) throws

    @discardableResult
    func createBackupFile() throws -> URL

    func unzipFile(fileURL: URL, documentURL: URL) throws
}
