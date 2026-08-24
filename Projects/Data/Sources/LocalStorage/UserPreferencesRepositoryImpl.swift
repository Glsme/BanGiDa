//
//  UserPreferencesRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import Domain
import CoreKit

package final class UserPreferencesRepositoryImpl: UserPreferencesRepository {
    private let userDefaults: UserDefaults

    package init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    package func load() -> UserPreferences {
        UserPreferences(
            isFirstLaunchCompleted: userDefaults.bool(forKey: UserDefaultsKey.first.rawValue),
            petName: userDefaults.string(forKey: UserDefaultsKey.name.rawValue),
            storyAgreement: userDefaults.bool(forKey: UserDefaultsKey.storyAgreement.rawValue)
        )
    }

    package func save(_ preferences: UserPreferences) {
        userDefaults.set(preferences.isFirstLaunchCompleted, forKey: UserDefaultsKey.first.rawValue)
        if let petName = preferences.petName {
            userDefaults.set(petName, forKey: UserDefaultsKey.name.rawValue)
        } else {
            userDefaults.removeObject(forKey: UserDefaultsKey.name.rawValue)
        }
        userDefaults.set(preferences.storyAgreement, forKey: UserDefaultsKey.storyAgreement.rawValue)
    }

    package func getPetName() -> String? {
        userDefaults.string(forKey: UserDefaultsKey.name.rawValue)
    }

    package func setPetName(_ name: String) {
        userDefaults.set(name, forKey: UserDefaultsKey.name.rawValue)
    }

    package func isFirstLaunchCompleted() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.first.rawValue)
    }

    package func setFirstLaunchCompleted() {
        userDefaults.set(true, forKey: UserDefaultsKey.first.rawValue)
    }

    package func getStoryAgreement() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.storyAgreement.rawValue)
    }

    package func setStoryAgreement(_ agreed: Bool) {
        userDefaults.set(agreed, forKey: UserDefaultsKey.storyAgreement.rawValue)
    }
}
