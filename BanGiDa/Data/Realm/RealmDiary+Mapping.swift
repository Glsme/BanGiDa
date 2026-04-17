//
//  RealmDiary+Mapping.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import RealmSwift

extension Diary {
    func toDomain() -> DiaryEntry {
        DiaryEntry(
            id: objectId.stringValue,
            type: DiaryType(rawValue: type?.rawValue ?? 0) ?? .memo,
            date: date,
            registeredDate: regDate,
            animalName: animalName,
            content: content,
            photoFileName: photo,
            alarmTitle: alarmTitle,
            repeatRule: repeatRule
        )
    }

    static func fromDomain(_ entry: DiaryEntry) -> Diary {
        let diary = Diary(
            type: RealmDiaryType(rawValue: entry.type.rawValue),
            date: entry.date,
            regDate: entry.registeredDate,
            animalName: entry.animalName,
            content: entry.content,
            photo: entry.photoFileName,
            alarmTitle: entry.alarmTitle,
            repeatRule: entry.repeatRule
        )
        return diary
    }
}
