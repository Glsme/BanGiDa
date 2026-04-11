//
//  UpdateDiaryUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol UpdateDiaryUseCase {
    func execute(entry: DiaryEntry, photoData: Data?) throws
}

final class UpdateDiaryUseCaseImpl: UpdateDiaryUseCase {
    private let diaryRepository: DiaryRepository
    private let imageRepository: ImageRepository

    init(diaryRepository: DiaryRepository, imageRepository: ImageRepository) {
        self.diaryRepository = diaryRepository
        self.imageRepository = imageRepository
    }

    func execute(entry: DiaryEntry, photoData: Data?) throws {
        if let photoData = photoData {
            let fileName = "\(entry.id).jpg"
            imageRepository.saveImageData(fileName: fileName, data: photoData)
            var updatedEntry = entry
            updatedEntry.photoFileName = fileName
            try diaryRepository.update(updatedEntry)
        } else {
            try diaryRepository.update(entry)
        }
    }
}
