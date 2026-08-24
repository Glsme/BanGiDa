//
//  ImageRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import Domain

package final class ImageRepositoryImpl: ImageRepository {
    private let documentManager: DocumentManaging

    package init(documentManager: DocumentManaging = DocumentManager()) {
        self.documentManager = documentManager
    }

    package func loadImageData(fileName: String) -> Data? {
        documentManager.loadImageDataFromDocument(fileName: fileName)
    }

    package func saveImageData(fileName: String, data: Data) throws {
        documentManager.createImagesDirectoryPath()

        guard let documentDirectory = documentManager.documentDirectoryPath() else {
            throw DocumentError.fetchDirectoryPathError
        }

        let fileURL = documentDirectory
            .appendingPathComponent("images")
            .appendingPathComponent(fileName)

        try data.write(to: fileURL)
    }

    package func removeImage(fileName: String) {
        documentManager.removeImageFromDocument(fileName: fileName)
    }

    package func removeAll() {
        documentManager.removeAllImagesFromDocument()
    }
}
