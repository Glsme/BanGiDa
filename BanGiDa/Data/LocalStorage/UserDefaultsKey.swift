//
//  UserDefaultsKey.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import Foundation

enum UserDefaultsKey: String {
    case first = "first"
    case name = "name"
    case storyAgreement = "storyAgreement" // 레거시 (마이그레이션용 유지)
    case storyAgreementVersion = "storyAgreementVersion" // 신규 Int
}
