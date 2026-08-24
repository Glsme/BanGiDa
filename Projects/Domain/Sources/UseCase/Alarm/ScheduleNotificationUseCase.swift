//
//  ScheduleNotificationUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol ScheduleNotificationUseCase {
    func execute(identifier: String, title: String, body: String, date: Date, repeatRule: AlarmRepeat)
    func execute(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat)
}

package final class ScheduleNotificationUseCaseImpl: ScheduleNotificationUseCase {
    private let notificationRepository: NotificationRepository

    package init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    package func execute(identifier: String, title: String, body: String, date: Date, repeatRule: AlarmRepeat) {
        notificationRepository.schedule(identifier: identifier, title: title, body: body, date: date, repeatRule: repeatRule)
    }

    package func execute(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        notificationRepository.schedule(title: title, body: body, date: date, index: index, repeatRule: repeatRule)
    }
}
