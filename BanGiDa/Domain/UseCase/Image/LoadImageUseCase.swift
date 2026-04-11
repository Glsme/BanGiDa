//
//  LoadImageUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol LoadImageUseCase {
    func execute(fileName: String) -> Data?
}

final class LoadImageUseCaseImpl: LoadImageUseCase {
    private let imageRepository: ImageRepository

    init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }

    func execute(fileName: String) -> Data? {
        imageRepository.loadImageData(fileName: fileName)
    }
}
