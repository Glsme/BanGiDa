//
//  DiaryType.swift
//  BanGiDa
//

import Foundation

enum DiaryType: Int, CaseIterable, Codable {
    case memo = 0
    case alarm
    case hospital
    case shower
    case pill
    case abnormal
}
