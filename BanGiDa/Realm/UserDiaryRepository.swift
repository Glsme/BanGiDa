//
//  UserMemoRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/14.
//

import Foundation
import RealmSwift

class UserDiaryRepository {
    static let shared = UserDiaryRepository()
    
    private init() { }
    
    let localRealm = try! Realm()
    
    var primaryKey: ObjectId?
    
    func write(_ task: Diary) {
        try! localRealm.write {
            localRealm.add(task)
        }
    }
    
    func delete(_ task: Diary) {
        try! localRealm.write {
            localRealm.delete(task)
        }
    }
    
    func fetch() -> Results<Diary> {
        return localRealm.objects(Diary.self).sorted(byKeyPath: "regDate", ascending: false)
    }
    
    func filter(index: Int) -> Results<Diary> {
        return localRealm.objects(Diary.self).filter("type == \(index)").sorted(byKeyPath: "regDate", ascending: false)
    }
    
    func update(_ task: Diary, date: Date, regDate: Date, content: String, image: String?) {
        try! localRealm.write {
            task.date = date
            task.regDate = regDate
            task.content = content
            task.photo = image
        }
    }
}
