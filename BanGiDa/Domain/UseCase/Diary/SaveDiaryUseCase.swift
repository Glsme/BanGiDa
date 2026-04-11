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

        try diaryRepository.save(entry)

        // 저장 후 실제 Realm이 생성한 ID로 최신 항목을 가져옴
        let saved = diaryRepository.fetchByDate(date)
            .first(where: { $0.content == content && $0.registeredDate >= entry.registeredDate })

        if let saved = saved, let photoData = photoData {
            imageRepository.saveImageData(fileName: "\(saved.id).jpg", data: photoData)
            var updated = saved
            updated.photoFileName = "\(saved.id).jpg"
            try diaryRepository.update(updated)
            return updated
        }

        return saved ?? entry
    }
}
