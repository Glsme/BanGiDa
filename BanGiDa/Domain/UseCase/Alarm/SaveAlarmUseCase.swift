//
//  SaveAlarmUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol SaveAlarmUseCase {
    func execute(date: Date, content: String, animalName: String, alarmTitle: String, repeatRule: AlarmRepeat) throws -> DiaryEntry
}

final class SaveAlarmUseCaseImpl: SaveAlarmUseCase {
    private let diaryRepository: DiaryRepository
    private let notificationRepository: NotificationRepository

    init(diaryRepository: DiaryRepository, notificationRepository: NotificationRepository) {
        self.diaryRepository = diaryRepository
        self.notificationRepository = notificationRepository
    }

    func execute(date: Date, content: String, animalName: String, alarmTitle: String, repeatRule: AlarmRepeat) throws -> DiaryEntry {
        let entry = DiaryEntry(
            id: UUID().uuidString,
            type: .alarm,
            date: date,
            registeredDate: Date(),
            animalName: animalName,
            content: content,
            photoFileName: nil,
            alarmTitle: alarmTitle,
            repeatRule: repeatRule
        )

        try diaryRepository.save(entry)

        let saved = diaryRepository.fetchByDateAndType(date: date, type: .alarm)
            .first(where: { $0.content == content && $0.registeredDate >= entry.registeredDate })

        let savedEntry = saved ?? entry

        notificationRepository.schedule(
            title: alarmTitle,
            body: content,
            date: date,
            index: 1,
            repeatRule: repeatRule
        )

        return savedEntry
    }
}
