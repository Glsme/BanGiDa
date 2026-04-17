//
//  SaveDiaryUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol SaveDiaryUseCase {
    func execute(type: DiaryType, date: Date, content: String, animalName: String, photoData: Data?, alarmTitle: String?, repeatRule: AlarmRepeat) throws -> DiaryEntry
}

final class SaveDiaryUseCaseImpl: SaveDiaryUseCase {
    private let diaryRepository: DiaryRepository
    private let imageRepository: ImageRepository

    init(diaryRepository: DiaryRepository, imageRepository: ImageRepository) {
        self.diaryRepository = diaryRepository
        self.imageRepository = imageRepository
    }

    func execute(type: DiaryType, date: Date, content: String, animalName: String, photoData: Data?, alarmTitle: String?, repeatRule: AlarmRepeat) throws -> DiaryEntry {
        let entry = DiaryEntry(
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

        let saved = try diaryRepository.save(entry)

        guard let photoData = photoData else {
            return saved
        }

        let fileName = "\(saved.id).jpg"
        imageRepository.saveImageData(fileName: fileName, data: photoData)

        var updated = saved
        updated.photoFileName = fileName
        try diaryRepository.update(updated)
        return updated
    }
}
