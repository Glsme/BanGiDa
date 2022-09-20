//
//  RealmModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/14.
//

import Foundation
import RealmSwift

enum RealmDiaryType: Int, PersistableEnum {
    case memo = 0
    case alarm
    case hospital
    case shower
    case pill
    case abnormal
}

enum DiaryType: Int {
    case memo = 0
    case alarm
    case hospital
    case shower
    case pill
    case abnormal
}

class Diary: Object {
    @Persisted var type: RealmDiaryType?
    @Persisted var date = Date()
    @Persisted var regDate = Date()
    @Persisted var animalName: String
    @Persisted var content: String
    @Persisted var photo: String?
    @Persisted var alarmTitle: String?
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    convenience init(type: RealmDiaryType?, date: Date, regDate: Date, animalName: String, content: String, photo: String?, alarmTitle: String?) {
        self.init()
        self.type = type
        self.date = date
        self.regDate = regDate
        self.animalName = animalName
        self.content = content
        self.photo = photo
        self.alarmTitle = alarmTitle
    }
}
