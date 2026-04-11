//
//  RestoreNotificationsUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol RestoreNotificationsUseCase {
    func execute()
}

final class RestoreNotificationsUseCaseImpl: RestoreNotificationsUseCase {
    private let diaryRepository: DiaryRepository
    private let notificationRepository: NotificationRepository

    init(diaryRepository: DiaryRepository, notificationRepository: NotificationRepository) {
        self.diaryRepository = diaryRepository
        self.notificationRepository = notificationRepository
    }

    func execute() {
        let alarms = diaryRepository.fetchByType(DiaryType(rawValue: 1)!)
        for (index, alarm) in alarms.enumerated() {
            if alarm.date > Date() {
                notificationRepository.schedule(
                    title: alarm.alarmTitle ?? alarm.animalName,
                    body: alarm.content,
                    date: alarm.date,
                    index: index,
                    repeatRule: alarm.repeatRule
                )
            }
        }
    }
}
