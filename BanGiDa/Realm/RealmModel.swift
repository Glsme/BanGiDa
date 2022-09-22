//
//  RealmModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/14.
//

import Foundation
import RealmSwift

enum RealmDiaryType: Int, PersistableEnum, Codable {
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

class Diary: Object, Codable {
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
    
    enum CodingKeys: String, CodingKey {
        case objectId
        case type
        case date
        case regDate
        case animalName
        case content
        case photo
        case alarmTitle
    }
    
    func encode(to encoder: Encoder) throws {
        var containter = encoder.container(keyedBy: CodingKeys.self)
        try containter.encode(objectId, forKey: .objectId)
        try containter.encode(type, forKey: .type)
        try containter.encode(date, forKey: .date)
        try containter.encode(regDate, forKey: .regDate)
        try containter.encode(animalName, forKey: .animalName)
        try containter.encode(content, forKey: .content)
        try containter.encode(photo, forKey: .photo)
        try containter.encode(alarmTitle, forKey: .alarmTitle)
    }
}
