//
//  UserPreferences.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package struct UserPreferences {
    package var isFirstLaunchCompleted: Bool
    package var petName: String?
    package var storyAgreement: Bool

    package init(isFirstLaunchCompleted: Bool, petName: String? = nil, storyAgreement: Bool) {
        self.isFirstLaunchCompleted = isFirstLaunchCompleted
        self.petName = petName
        self.storyAgreement = storyAgreement
    }
}
