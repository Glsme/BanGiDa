//
//  UpdateAlarmUseCase.swift
//  BanGiDa
//
//  Created by OpenAI Codex on 2026/04/17.
//

import Foundation

package protocol UpdateAlarmUseCase {
    func execute(entry: DiaryEntry) throws -> DiaryEntry
}

package final class UpdateAlarmUseCaseImpl: UpdateAlarmUseCase {
    private let diaryRepository: DiaryRepository
    private let notificationRepository: NotificationRepository

    package init(diaryRepository: DiaryRepository, notificationRepository: NotificationRepository) {
        self.diaryRepository = diaryRepository
        self.notificationRepository = notificationRepository
    }

    package func execute(entry: DiaryEntry) throws -> DiaryEntry {
        try diaryRepository.update(entry)
        notificationRepository.remove(identifier: entry.id)

        if entry.date > Date() || entry.repeatRule != .none {
            notificationRepository.schedule(
                identifier: entry.id,
                title: entry.alarmTitle ?? entry.animalName,
                body: entry.content,
                date: entry.date,
                repeatRule: entry.repeatRule
            )
        }

        return entry
    }
}
