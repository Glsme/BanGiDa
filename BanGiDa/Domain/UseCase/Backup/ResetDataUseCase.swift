//
//  ResetDataUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol ResetDataUseCase {
    func execute() throws
}

final class ResetDataUseCaseImpl: ResetDataUseCase {
    private let diaryRepository: DiaryRepository
    private let notificationRepository: NotificationRepository
    private let userPreferencesRepository: UserPreferencesRepository

    init(diaryRepository: DiaryRepository, notificationRepository: NotificationRepository, userPreferencesRepository: UserPreferencesRepository) {
        self.diaryRepository = diaryRepository
        self.notificationRepository = notificationRepository
        self.userPreferencesRepository = userPreferencesRepository
    }

    func execute() throws {
        var prefs = userPreferencesRepository.load()
        prefs.isFirstLaunchCompleted = false
        prefs.petName = nil
        userPreferencesRepository.save(prefs)
        try diaryRepository.deleteAll()
        notificationRepository.removeAllPending()
        notificationRepository.removeAllDelivered()
    }
}
