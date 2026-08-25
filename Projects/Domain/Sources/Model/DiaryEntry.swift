//
//  DiaryEntry.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package struct DiaryEntry: Identifiable {
    package let id: String
    package var type: DiaryType
    package var date: Date
    package var registeredDate: Date
    package var animalName: String
    package var content: String
    package var photoFileName: String?
    package var alarmTitle: String?
    package var repeatRule: AlarmRepeat

    // 멤버와이즈 이니셜라이저는 접근 수준이 internal을 넘지 못해
    // 모듈 밖에서 생성할 수 없다. 명시적으로 노출한다.
    package init(
        id: String,
        type: DiaryType,
        date: Date,
        registeredDate: Date,
        animalName: String,
        content: String,
        photoFileName: String? = nil,
        alarmTitle: String? = nil,
        repeatRule: AlarmRepeat
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.registeredDate = registeredDate
        self.animalName = animalName
        self.content = content
        self.photoFileName = photoFileName
        self.alarmTitle = alarmTitle
        self.repeatRule = repeatRule
    }
}
