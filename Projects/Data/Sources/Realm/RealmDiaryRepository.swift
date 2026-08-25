//
//  RealmDiaryRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import RealmSwift
import Domain

package enum RealmDiaryRepositoryError: Error {
    case invalidObjectId(String)
    case notFound(String)
}

package final class RealmDiaryRepository: DiaryRepository {

    // 암묵적 이니셜라이저는 internal이라 모듈 밖(DIContainer)에서 생성할 수 없다.
    package init() {}

    private func makeRealm() throws -> Realm {
        try Realm()
    }

    private func dayRange(from date: Date) -> (start: Date, end: Date) {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: date)
        let end = calendar.date(byAdding: .day, value: 1, to: start) ?? Date(timeInterval: 86400, since: start)
        return (start, end)
    }

    package func fetchAll() -> [DiaryEntry] {
        guard let realm = try? makeRealm() else { return [] }
        return realm.objects(Diary.self)
            .sorted(byKeyPath: "regDate", ascending: false)
            .map { $0.toDomain() }
    }

    package func fetchByDate(_ date: Date) -> [DiaryEntry] {
        guard let realm = try? makeRealm() else { return [] }
        let range = dayRange(from: date)
        return realm.objects(Diary.self)
            .filter("date >= %@ AND date < %@", range.start, range.end)
            .map { $0.toDomain() }
    }

    package func fetchByType(_ type: DiaryType) -> [DiaryEntry] {
        guard let realm = try? makeRealm() else { return [] }
        return realm.objects(Diary.self)
            .filter("type == \(type.rawValue)")
            .sorted(byKeyPath: "regDate", ascending: false)
            .map { $0.toDomain() }
    }

    package func fetchByDateAndType(date: Date, type: DiaryType) -> [DiaryEntry] {
        guard let realm = try? makeRealm() else { return [] }
        let range = dayRange(from: date)
        return realm.objects(Diary.self)
            .filter("type == \(type.rawValue) AND date >= %@ AND date < %@", range.start, range.end)
            .sorted(byKeyPath: "regDate", ascending: false)
            .map { $0.toDomain() }
    }

    @discardableResult
    package func save(_ entry: DiaryEntry) throws -> DiaryEntry {
        let realm = try makeRealm()
        let diary = Diary.fromDomain(entry)
        try realm.write {
            realm.add(diary)
        }
        return diary.toDomain()
    }

    package func update(_ entry: DiaryEntry) throws {
        let realm = try makeRealm()
        let objectId = try ObjectId(string: entry.id)
        guard let diary = realm.object(ofType: Diary.self, forPrimaryKey: objectId) else {
            throw RealmDiaryRepositoryError.notFound(entry.id)
        }

        try realm.write {
            diary.date = entry.date
            diary.regDate = entry.registeredDate
            diary.content = entry.content
            diary.photo = entry.photoFileName
            diary.alarmTitle = entry.alarmTitle
            diary.repeatRule = entry.repeatRule
        }
    }

    package func delete(_ entry: DiaryEntry) throws {
        let realm = try makeRealm()
        let objectId = try ObjectId(string: entry.id)
        guard let diary = realm.object(ofType: Diary.self, forPrimaryKey: objectId) else {
            throw RealmDiaryRepositoryError.notFound(entry.id)
        }

        try realm.write {
            realm.delete(diary)
        }
    }

    package func deleteAll() throws {
        let realm = try makeRealm()
        try realm.write {
            realm.deleteAll()
        }
    }

    package func findByID(_ id: String) -> DiaryEntry? {
        guard let realm = try? makeRealm() else { return nil }
        guard let objectId = try? ObjectId(string: id) else { return nil }
        return realm.object(ofType: Diary.self, forPrimaryKey: objectId)?.toDomain()
    }
}
