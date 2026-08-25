//
//  RequestNotificationAuthorizationUseCase.swift
//  BanGiDa
//
//  Created by Claude on 4/16/26.
//

import Foundation

package protocol RequestNotificationAuthorizationUseCase {
    func execute() async -> Bool
}

package final class RequestNotificationAuthorizationUseCaseImpl: RequestNotificationAuthorizationUseCase {
    private let notificationRepository: NotificationRepository

    package init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    package func execute() async -> Bool {
        await notificationRepository.requestAuthorization()
    }
}
