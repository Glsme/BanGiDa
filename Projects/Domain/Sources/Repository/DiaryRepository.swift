//
//  DiaryRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol DiaryRepository {
    func fetchAll() -> [DiaryEntry]
    func fetchByDate(_ date: Date) -> [DiaryEntry]
    func fetchByType(_ type: DiaryType) -> [DiaryEntry]
    func fetchByDateAndType(date: Date, type: DiaryType) -> [DiaryEntry]
    @discardableResult
    func save(_ entry: DiaryEntry) throws -> DiaryEntry
    func update(_ entry: DiaryEntry) throws
    func delete(_ entry: DiaryEntry) throws
    func deleteAll() throws
    func findByID(_ id: String) -> DiaryEntry?
}
