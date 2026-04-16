//
//  UserPreferencesUseCase.swift
//  BanGiDa
//
//  Created by Claude on 4/16/26.
//

import Foundation

protocol UserPreferencesUseCase {
    func getPetName() -> String?
    func setPetName(_ name: String)
    func isFirstLaunchCompleted() -> Bool
    func setFirstLaunchCompleted()
}

final class UserPreferencesUseCaseImpl: UserPreferencesUseCase {
    private let userPreferencesRepository: UserPreferencesRepository

    init(userPreferencesRepository: UserPreferencesRepository) {
        self.userPreferencesRepository = userPreferencesRepository
    }

    func getPetName() -> String? {
        userPreferencesRepository.getPetName()
    }

    func setPetName(_ name: String) {
        userPreferencesRepository.setPetName(name)
    }

    func isFirstLaunchCompleted() -> Bool {
        userPreferencesRepository.isFirstLaunchCompleted()
    }

    func setFirstLaunchCompleted() {
        userPreferencesRepository.setFirstLaunchCompleted()
    }
}
