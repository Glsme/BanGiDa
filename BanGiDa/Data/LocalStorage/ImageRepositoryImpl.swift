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

    func saveImageData(fileName: String, data: Data) {
        documentManager.saveImageDataFromDocument(fileName: fileName, image: data)
    }

    func removeImage(fileName: String) {
        documentManager.removeImageFromDocument(fileName: fileName)
    }

    func removeAll() {
        documentManager.removeAllImagesFromDocument()
    }
}
