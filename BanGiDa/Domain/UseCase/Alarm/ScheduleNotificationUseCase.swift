//
//  ScheduleNotificationUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol ScheduleNotificationUseCase {
    func execute(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat)
}

final class ScheduleNotificationUseCaseImpl: ScheduleNotificationUseCase {
    private let notificationRepository: NotificationRepository

    init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    func execute(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        notificationRepository.schedule(title: title, body: body, date: date, index: index, repeatRule: repeatRule)
    }
}
