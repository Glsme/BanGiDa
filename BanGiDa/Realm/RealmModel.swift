//
//  RealmModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/14.
//

import Foundation
import RealmSwift

class UserDiary: Object {
    @Persisted var diaryType: String
    @Persisted var date = Date()
    @Persisted var animalName: String
    @Persisted var diaryContent: String?
    
    @Persisted(primaryKey: true) var objectId: ObjectId
    
    convenience init(diaryType: String, date: Date, animalName: String, diaryContent: String?) {
        self.init()
        self.diaryType = diaryType
        self.date = date
        self.animalName = animalName
        self.diaryContent = diaryContent
    }
}
