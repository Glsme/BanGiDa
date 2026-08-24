//
//  SaveDiaryUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol SaveDiaryUseCase {
    func execute(type: DiaryType, date: Date, content: String, animalName: String, photoData: Data?, alarmTitle: String?, repeatRule: AlarmRepeat) throws -> DiaryEntry
}

package final class SaveDiaryUseCaseImpl: SaveDiaryUseCase {
    private let diaryRepository: DiaryRepository
    private let imageRepository: ImageRepository

    package init(diaryRepository: DiaryRepository, imageRepository: ImageRepository) {
        self.diaryRepository = diaryRepository
        self.imageRepository = imageRepository
    }

    package func execute(type: DiaryType, date: Date, content: String, animalName: String, photoData: Data?, alarmTitle: String?, repeatRule: AlarmRepeat) throws -> DiaryEntry {
        var entry = DiaryEntry(
            id: UUID().uuidString,
            type: type,
            date: date,
            registeredDate: Date(),
            animalName: animalName,
            content: content,
            photoFileName: nil,
            alarmTitle: alarmTitle,
            repeatRule: repeatRule
        )

        guard let photoData = photoData else {
            return try diaryRepository.save(entry)
        }

        let fileName = "\(entry.id).jpg"
        entry.photoFileName = fileName
        try imageRepository.saveImageData(fileName: fileName, data: photoData)

        return try diaryRepository.save(entry)
    }
}
