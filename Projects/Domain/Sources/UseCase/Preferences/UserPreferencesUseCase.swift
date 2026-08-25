//
//  UserPreferencesUseCase.swift
//  BanGiDa
//
//  Created by Claude on 4/16/26.
//

import Foundation

package protocol UserPreferencesUseCase {
    func getPetName() -> String?
    func setPetName(_ name: String)
    func isFirstLaunchCompleted() -> Bool
    func setFirstLaunchCompleted()
}

package final class UserPreferencesUseCaseImpl: UserPreferencesUseCase {
    private let userPreferencesRepository: UserPreferencesRepository

    package init(userPreferencesRepository: UserPreferencesRepository) {
        self.userPreferencesRepository = userPreferencesRepository
    }

    package func getPetName() -> String? {
        userPreferencesRepository.getPetName()
    }

    package func setPetName(_ name: String) {
        userPreferencesRepository.setPetName(name)
    }

    package func isFirstLaunchCompleted() -> Bool {
        userPreferencesRepository.isFirstLaunchCompleted()
    }

    package func setFirstLaunchCompleted() {
        userPreferencesRepository.setFirstLaunchCompleted()
    }
}
