//
//  Diary.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/14.
//

import Foundation
import RealmSwift
import Domain

enum RealmDiaryType: Int, PersistableEnum, Codable {
    case memo = 0
    case alarm
    case hospital
    case shower
    case pill
    case abnormal
}

class Diary: Object, Codable {
    private override init() { }
    
    @Persisted var type: RealmDiaryType?
    @Persisted var date = Date()
    @Persisted var regDate = Date()
    @Persisted var animalName: String
    @Persisted var content: String
    @Persisted var photo: String?
    @Persisted var alarmTitle: String?
    @Persisted var repeatRule: AlarmRepeat = .none
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    convenience init(type: RealmDiaryType?, date: Date, regDate: Date, animalName: String, content: String, photo: String?, alarmTitle: String?, repeatRule: AlarmRepeat = .none) {
        self.init()
        self.type = type
        self.date = date
        self.regDate = regDate
        self.animalName = animalName
        self.content = content
        self.photo = photo
        self.alarmTitle = alarmTitle
        self.repeatRule = repeatRule
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
        case repeatRule
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
        try containter.encode(repeatRule, forKey: .repeatRule)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self._objectId = try container.decode(Persisted<ObjectId>.self, forKey: .objectId)
        self._type = try container.decode(Persisted<RealmDiaryType?>.self, forKey: .type)
        self._date = try container.decode(Persisted<Date>.self, forKey: .date)
        self._regDate = try container.decode(Persisted<Date>.self, forKey: .regDate)
        self._animalName = try container.decode(Persisted<String>.self, forKey: .animalName)
        self._content = try container.decode(Persisted<String>.self, forKey: .content)
        self._photo = try container.decode(Persisted<String?>.self, forKey: .photo)
        self._alarmTitle = try container.decode(Persisted<String?>.self, forKey: .alarmTitle)
        
        if let decodedRepeatRule = try container.decodeIfPresent(Persisted<AlarmRepeat>.self, forKey: .repeatRule) {
            self._repeatRule = decodedRepeatRule
        } else {
            self.repeatRule = .none
        }
    }
}
