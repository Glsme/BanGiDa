//
//  UserPreferencesRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import Domain

final class UserPreferencesRepositoryImpl: UserPreferencesRepository {
    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func load() -> UserPreferences {
        UserPreferences(
            isFirstLaunchCompleted: userDefaults.bool(forKey: UserDefaultsKey.first.rawValue),
            petName: userDefaults.string(forKey: UserDefaultsKey.name.rawValue),
            storyAgreement: userDefaults.bool(forKey: UserDefaultsKey.storyAgreement.rawValue)
        )
    }

    func save(_ preferences: UserPreferences) {
        userDefaults.set(preferences.isFirstLaunchCompleted, forKey: UserDefaultsKey.first.rawValue)
        if let petName = preferences.petName {
            userDefaults.set(petName, forKey: UserDefaultsKey.name.rawValue)
        } else {
            userDefaults.removeObject(forKey: UserDefaultsKey.name.rawValue)
        }
        userDefaults.set(preferences.storyAgreement, forKey: UserDefaultsKey.storyAgreement.rawValue)
    }

    func getPetName() -> String? {
        userDefaults.string(forKey: UserDefaultsKey.name.rawValue)
    }

    func setPetName(_ name: String) {
        userDefaults.set(name, forKey: UserDefaultsKey.name.rawValue)
    }

    func isFirstLaunchCompleted() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.first.rawValue)
    }

    func setFirstLaunchCompleted() {
        userDefaults.set(true, forKey: UserDefaultsKey.first.rawValue)
    }

    func getStoryAgreement() -> Bool {
        userDefaults.bool(forKey: UserDefaultsKey.storyAgreement.rawValue)
    }

    func setStoryAgreement(_ agreed: Bool) {
        userDefaults.set(agreed, forKey: UserDefaultsKey.storyAgreement.rawValue)
    }
}
