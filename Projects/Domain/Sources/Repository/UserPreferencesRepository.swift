//
//  UserPreferencesRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol UserPreferencesRepository {
    func load() -> UserPreferences
    func save(_ preferences: UserPreferences)
    func getPetName() -> String?
    func setPetName(_ name: String)
    func isFirstLaunchCompleted() -> Bool
    func setFirstLaunchCompleted()
    func getStoryAgreement() -> Bool
    func setStoryAgreement(_ agreed: Bool)
}
