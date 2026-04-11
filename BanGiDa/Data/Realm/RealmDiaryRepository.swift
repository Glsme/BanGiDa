//
//  RealmDiaryRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import RealmSwift

final class RealmDiaryRepository: DiaryRepository {
    private let realm: Realm

    init() {
        self.realm = try! Realm()
    }

    func fetchAll() -> [DiaryEntry] {
        realm.objects(Diary.self)
            .sorted(byKeyPath: "regDate", ascending: false)
            .map { $0.toDomain() }
    }

    func fetchByDate(_ date: Date) -> [DiaryEntry] {
        let nextDay = Date(timeInterval: 86400, since: date)
        return realm.objects(Diary.self)
            .filter("date >= %@ AND date < %@", date, nextDay)
            .map { $0.toDomain() }
    }

    func fetchByType(_ type: DiaryType) -> [DiaryEntry] {
        realm.objects(Diary.self)
            .filter("type == \(type.rawValue)")
            .sorted(byKeyPath: "regDate", ascending: false)
            .map { $0.toDomain() }
    }

    func fetchByDateAndType(date: Date, type: DiaryType) -> [DiaryEntry] {
        let nextDay = Date(timeInterval: 86400, since: date)
        return realm.objects(Diary.self)
            .filter("type == \(type.rawValue) AND date >= %@ AND date < %@", date, nextDay)
            .sorted(byKeyPath: "regDate", ascending: false)
            .map { $0.toDomain() }
    }

    func save(_ entry: DiaryEntry) throws {
        let diary = Diary.fromDomain(entry)
        try realm.write {
            realm.add(diary)
        }
    }

    func update(_ entry: DiaryEntry) throws {
        guard let objectId = try? ObjectId(string: entry.id) else { return }
        guard let diary = realm.object(ofType: Diary.self, forPrimaryKey: objectId) else { return }

        try realm.write {
            diary.date = entry.date
            diary.regDate = entry.registeredDate
            diary.content = entry.content
            diary.photo = entry.photoFileName
            diary.alarmTitle = entry.alarmTitle
            diary.repeatRule = entry.repeatRule
        }
    }

    func delete(_ entry: DiaryEntry) throws {
        guard let objectId = try? ObjectId(string: entry.id) else { return }
        guard let diary = realm.object(ofType: Diary.self, forPrimaryKey: objectId) else { return }

        try realm.write {
            realm.delete(diary)
        }
    }

    func deleteAll() throws {
        try realm.write {
            realm.deleteAll()
        }
    }

    func findByID(_ id: String) -> DiaryEntry? {
        guard let objectId = try? ObjectId(string: id) else { return nil }
        return realm.object(ofType: Diary.self, forPrimaryKey: objectId)?.toDomain()
    }
}
