//
//  LoadImageUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol LoadImageUseCase {
    func execute(fileName: String) -> Data?
}

package final class LoadImageUseCaseImpl: LoadImageUseCase {
    private let imageRepository: ImageRepository

    package init(imageRepository: ImageRepository) {
        self.imageRepository = imageRepository
    }

    package func execute(fileName: String) -> Data? {
        imageRepository.loadImageData(fileName: fileName)
    }
}
