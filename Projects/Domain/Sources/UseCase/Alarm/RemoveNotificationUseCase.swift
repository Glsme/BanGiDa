//
//  RemoveNotificationUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol RemoveNotificationUseCase {
    func execute(identifier: String)
    func execute(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat)
}

package final class RemoveNotificationUseCaseImpl: RemoveNotificationUseCase {
    private let notificationRepository: NotificationRepository

    package init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    package func execute(identifier: String) {
        notificationRepository.remove(identifier: identifier)
    }

    package func execute(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        notificationRepository.remove(title: title, body: body, date: date, index: index, repeatRule: repeatRule)
    }
}
