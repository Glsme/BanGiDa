//
//  RequestNotificationAuthorizationUseCase.swift
//  BanGiDa
//
//  Created by Claude on 4/16/26.
//

import Foundation

protocol RequestNotificationAuthorizationUseCase {
    func execute() async -> Bool
}

final class RequestNotificationAuthorizationUseCaseImpl: RequestNotificationAuthorizationUseCase {
    private let notificationRepository: NotificationRepository

    init(notificationRepository: NotificationRepository) {
        self.notificationRepository = notificationRepository
    }

    func execute() async -> Bool {
        await notificationRepository.requestAuthorization()
    }
}
