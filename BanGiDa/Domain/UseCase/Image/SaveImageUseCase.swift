//
//  SaveImageUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol SaveImageUseCase {
    func execute(fileName: String, data: Data)
}

final class SaveImageUseCaseImpl: SaveImageUseCase {
    private let imageRepository: ImageRepository

    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }

    func execute(fileName: String, data: Data) {
        imageRepository.saveImageData(fileName: fileName, data: data)
    }
}
