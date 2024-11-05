//
//  UserMemoRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/14.
//

import Foundation
import RealmSwift

final class UserDiaryRepository {
    static let shared = UserDiaryRepository()
    
    private init() {
        diaryList = localRealm.objects(Diary.self).sorted(byKeyPath: "regDate", ascending: false)
    }

    let localRealm = try! Realm()
    
//    var primaryKey: ObjectId?
    
    func write(_ task: Diary) throws {
        try localRealm.write {
            localRealm.add(task)
        }
    }
    
    func fetchDate(date: Date) -> Results<Diary> {
        return localRealm.objects(Diary.self).filter("date >= %@ AND date < %@", date, Date(timeInterval: 86400, since: date)) // NSPredicate
    }
    
    func delete(_ task: Diary) {
        try! localRealm.write {
            localRealm.delete(task)
            print("delete success!")
        }
    }
    
    func fetch() -> Results<Diary> {
        return localRealm.objects(Diary.self).sorted(byKeyPath: "regDate", ascending: false)
    }
    
    func filter(index: Int) -> Results<Diary> {
        return localRealm.objects(Diary.self).filter("type == \(index)").sorted(byKeyPath: "regDate", ascending: false)
    }
    
    func filterToDate(date: Date, index: Int) -> Results<Diary> {
        return localRealm.objects(Diary.self).filter("type == \(index) AND date >= %@ AND date < %@", date, Date(timeInterval: 86400, since: date)).sorted(byKeyPath: "regDate", ascending: false)
    }
    
    func update(_ task: Diary, date: Date, regDate: Date, content: String, image: String?, alarmTitle: String?) {
        try! localRealm.write {
            task.date = date
            task.regDate = regDate
            task.content = content
            task.photo = image
            task.alarmTitle = alarmTitle
        }
    }
    
    func deleteAll() {
        try! localRealm.write {
            localRealm.deleteAll()
        }
    }
    
    //MARK: - json
    let documentManager = DocumentManager()
    
    var diaryList: Results<Diary>
    
    private lazy var dateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        return dateFormatter
    }()
    
    func saveEncodedDataToDocument() throws {
        let encodedData = try encodeData(diaryList)
        
        try documentManager.saveDataToDocument(data: encodedData)
    }
    
    func encodeData(_ data: Results<Diary>) throws -> Data {
        do {
            let encoder = JSONEncoder()
            
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            
            let encodedData: Data = try encoder.encode(data)
            
            return encodedData
        }
        catch {
            throw CodableError.jsonEncodeError
        }
    }
    
    func decodeData() throws -> Data {
        guard let path = documentManager.documentDirectoryPath() else { throw
            DocumentError.fetchJsonDataError
        }
//        print(path)
        
        let dataPath = path.appendingPathComponent("encodedData.json")
        
//        print(dataPath)
        do {
            return try Data(contentsOf: dataPath)
        } catch {
            throw DocumentError.fetchJsonDataError
        }
    }
    
    func restoreRealmForBackupFile() throws {
        let jsonData = try decodeData()
        
        guard let decodedData = try decodeDiary(jsonData) else { return }
        
        try localRealm.write {
            localRealm.deleteAll()
            localRealm.add(decodedData)
        }
    }
    
    
    func decodeDiary(_ diaryData: Data) throws -> [Diary]? {
        do {
            let decoder = JSONDecoder()
//            decoder.dateDecodingStrategy = . iso8601
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            let decodedData: [Diary] = try decoder.decode([Diary].self, from: diaryData)
//            print(decodedData)
            return decodedData
        } catch {
            throw CodableError.jsonDecodeError
        }
    }
}
