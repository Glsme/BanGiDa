//
//  UserMemoRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/14.
//

import Foundation
import RealmSwift

class UserMemoRepository {
    static let shared = UserMemoRepository()
    
    private init() { }
    
    let localRealm = try! Realm()
    
    func write(_ task: UserDiary) {
        try! localRealm.write {
            localRealm.add(task)
        }
    }
    
    func delete(_ task: UserDiary) {
        try! localRealm.write {
            localRealm.delete(task)
        }
    }
    
    func fetch() -> Results<UserDiary> {
        return localRealm.objects(UserDiary.self).sorted(byKeyPath: "date", ascending: false)
    }
}
