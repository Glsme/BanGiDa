//
//  SaveImageUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol SaveImageUseCase {
    func execute(fileName: String, data: Data) throws
}

package final class SaveImageUseCaseImpl: SaveImageUseCase {
    private let imageRepository: ImageRepository

    package init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }

    package func execute(fileName: String, data: Data) throws {
        try imageRepository.saveImageData(fileName: fileName, data: data)
    }
}
