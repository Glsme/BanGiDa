//
//  DiaryRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol DiaryRepository {
    func fetchAll() -> [DiaryEntry]
    func fetchByDate(_ date: Date) -> [DiaryEntry]
    func fetchByType(_ type: DiaryType) -> [DiaryEntry]
    func fetchByDateAndType(date: Date, type: DiaryType) -> [DiaryEntry]
    func save(_ entry: DiaryEntry) throws
    func update(_ entry: DiaryEntry) throws
    func delete(_ entry: DiaryEntry) throws
    func deleteAll() throws
    func findByID(_ id: String) -> DiaryEntry?
}
