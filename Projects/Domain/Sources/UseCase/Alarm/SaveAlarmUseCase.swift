//
//  SaveAlarmUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol SaveAlarmUseCase {
    func execute(date: Date, content: String, animalName: String, alarmTitle: String, repeatRule: AlarmRepeat) throws -> DiaryEntry
}

package final class SaveAlarmUseCaseImpl: SaveAlarmUseCase {
    private let diaryRepository: DiaryRepository
    private let notificationRepository: NotificationRepository

    package init(diaryRepository: DiaryRepository, notificationRepository: NotificationRepository) {
        self.diaryRepository = diaryRepository
        self.notificationRepository = notificationRepository
    }

    package func execute(date: Date, content: String, animalName: String, alarmTitle: String, repeatRule: AlarmRepeat) throws -> DiaryEntry {
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

        let savedEntry = try diaryRepository.save(entry)

        if date > Date() || repeatRule != .none {
            notificationRepository.schedule(
                identifier: savedEntry.id,
                title: alarmTitle,
                body: content,
                date: date,
                repeatRule: repeatRule
            )
        }

        return savedEntry
    }
}
