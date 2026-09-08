//
//  RealmDiary+Mapping.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import RealmSwift

extension Diary {
    /// v1.x~2.0.0은 사진을 `<objectId>.jpg`로 저장하면서 `photo`에는 빈 문자열을 넣었다.
    /// 빈 값을 그대로 파일명으로 쓰면 `images/` 디렉터리 자체를 가리켜 사진을 찾지 못하므로,
    /// 저장된 파일명이 없으면 레거시 규칙으로 되살린다. 파일이 없는 항목은 로더가 nil을 돌려주므로 무해하다.
    static func legacyPhotoFileName(for objectId: ObjectId) -> String {
        "\(objectId.stringValue).jpg"
    }

    static func resolvePhotoFileName(stored photo: String?, objectId: ObjectId) -> String {
        if let photo, !photo.isEmpty {
            return photo
        }
        return legacyPhotoFileName(for: objectId)
    }

    func toDomain() -> DiaryEntry {
        DiaryEntry(
            id: objectId.stringValue,
            type: DiaryType(rawValue: type?.rawValue ?? 0) ?? .memo,
            date: date,
            registeredDate: regDate,
            animalName: animalName,
            content: content,
            photoFileName: Self.resolvePhotoFileName(stored: photo, objectId: objectId),
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
