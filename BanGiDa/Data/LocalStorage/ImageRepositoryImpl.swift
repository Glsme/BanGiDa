//
//  ImageRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

final class ImageRepositoryImpl: ImageRepository {
    private let documentManager: DocumentManager

    init(documentManager: DocumentManager = DocumentManager()) {
        self.documentManager = documentManager
    }

    func loadImageData(fileName: String) -> Data? {
        documentManager.loadImageDataFromDocument(fileName: fileName)
    }

    func saveImageData(fileName: String, data: Data) throws {
        documentManager.createImagesDirectoryPath()

        guard let documentDirectory = documentManager.documentDirectoryPath() else {
            throw DocumentError.fetchDirectoryPathError
        }

        let fileURL = documentDirectory
            .appendingPathComponent("images")
            .appendingPathComponent(fileName)

        try data.write(to: fileURL)
    }

    func removeImage(fileName: String) {
        documentManager.removeImageFromDocument(fileName: fileName)
    }

    func removeAll() {
        documentManager.removeAllImagesFromDocument()
    }
}
