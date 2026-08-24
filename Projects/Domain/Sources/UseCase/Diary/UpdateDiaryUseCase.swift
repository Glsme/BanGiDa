//
//  UpdateDiaryUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol UpdateDiaryUseCase {
    func execute(entry: DiaryEntry, photoData: Data?) throws
}

package final class UpdateDiaryUseCaseImpl: UpdateDiaryUseCase {
    private let diaryRepository: DiaryRepository
    private let imageRepository: ImageRepository

    package init(diaryRepository: DiaryRepository, imageRepository: ImageRepository) {
        self.diaryRepository = diaryRepository
        self.imageRepository = imageRepository
    }

    package func execute(entry: DiaryEntry, photoData: Data?) throws {
        if let photoData = photoData {
            let fileName = "\(entry.id).jpg"
            try imageRepository.saveImageData(fileName: fileName, data: photoData)
            var updatedEntry = entry
            updatedEntry.photoFileName = fileName
            try diaryRepository.update(updatedEntry)
        } else {
            try diaryRepository.update(entry)
        }
    }
}
