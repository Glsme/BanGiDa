//
//  RestoreNotificationsUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol RestoreNotificationsUseCase {
    func execute()
}

package final class RestoreNotificationsUseCaseImpl: RestoreNotificationsUseCase {
    private let diaryRepository: DiaryRepository
    private let notificationRepository: NotificationRepository

    package init(diaryRepository: DiaryRepository, notificationRepository: NotificationRepository) {
        self.diaryRepository = diaryRepository
        self.notificationRepository = notificationRepository
    }

    package func execute() {
        notificationRepository.removeAllPending()
        let alarms = diaryRepository.fetchByType(.alarm)
        for alarm in alarms where alarm.date > Date() {
            notificationRepository.schedule(
                identifier: alarm.id,
                title: alarm.alarmTitle ?? alarm.animalName,
                body: alarm.content,
                date: alarm.date,
                repeatRule: alarm.repeatRule
            )
        }
    }
}
