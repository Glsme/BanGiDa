//
//  DeleteDiaryUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol DeleteDiaryUseCase {
    func execute(entry: DiaryEntry) throws
}

final class DeleteDiaryUseCaseImpl: DeleteDiaryUseCase {
    private let diaryRepository: DiaryRepository
    private let imageRepository: ImageRepository

    init(diaryRepository: DiaryRepository, imageRepository: ImageRepository) {
        self.diaryRepository = diaryRepository
        self.imageRepository = imageRepository
    }

    func execute(entry: DiaryEntry) throws {
        if let photo = entry.photoFileName, !photo.isEmpty {
            imageRepository.removeImage(fileName: photo)
        }
        try diaryRepository.delete(entry)
    }
}
