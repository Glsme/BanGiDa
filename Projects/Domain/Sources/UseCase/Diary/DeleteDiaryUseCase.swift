//
//  DeleteDiaryUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol DeleteDiaryUseCase {
    func execute(entry: DiaryEntry) throws
}

package final class DeleteDiaryUseCaseImpl: DeleteDiaryUseCase {
    private let diaryRepository: DiaryRepository
    private let imageRepository: ImageRepository

    package init(diaryRepository: DiaryRepository, imageRepository: ImageRepository) {
        self.diaryRepository = diaryRepository
        self.imageRepository = imageRepository
    }

    package func execute(entry: DiaryEntry) throws {
        if let photo = entry.photoFileName {
            imageRepository.removeImage(fileName: photo)
        }
        try diaryRepository.delete(entry)
    }
}
