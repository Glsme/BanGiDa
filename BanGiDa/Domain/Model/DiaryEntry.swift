//
//  DiaryEntry.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

struct DiaryEntry: Identifiable {
    let id: String
    var type: DiaryType
    var date: Date
    var registeredDate: Date
    var animalName: String
    var content: String
    var photoFileName: String?
    var alarmTitle: String?
    var repeatRule: AlarmRepeat
}
