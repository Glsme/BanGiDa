//
//  ResetDataUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol ResetDataUseCase {
    func execute() throws
}

package final class ResetDataUseCaseImpl: ResetDataUseCase {
    private let diaryRepository: DiaryRepository
    private let notificationRepository: NotificationRepository
    private let userPreferencesRepository: UserPreferencesRepository
    private let imageRepository: ImageRepository

    package init(
        diaryRepository: DiaryRepository,
        notificationRepository: NotificationRepository,
        userPreferencesRepository: UserPreferencesRepository,
        imageRepository: ImageRepository
    ) {
        self.diaryRepository = diaryRepository
        self.notificationRepository = notificationRepository
        self.userPreferencesRepository = userPreferencesRepository
        self.imageRepository = imageRepository
    }

    package func execute() throws {
        var prefs = userPreferencesRepository.load()
        prefs.isFirstLaunchCompleted = false
        prefs.petName = nil
        userPreferencesRepository.save(prefs)
        try diaryRepository.deleteAll()
        imageRepository.removeAll()
        notificationRepository.removeAllPending()
        notificationRepository.removeAllDelivered()
    }
}
