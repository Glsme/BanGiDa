//
//  FetchDiariesByDateUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol FetchDiariesByDateUseCase {
    func execute(date: Date) -> [DiaryType: [DiaryEntry]]
    func executeFlat(date: Date) -> [DiaryEntry]
}

package final class FetchDiariesByDateUseCaseImpl: FetchDiariesByDateUseCase {
    private let diaryRepository: DiaryRepository

    package init(diaryRepository: DiaryRepository) {
        self.diaryRepository = diaryRepository
    }

    package func execute(date: Date) -> [DiaryType: [DiaryEntry]] {
        var result: [DiaryType: [DiaryEntry]] = [:]
        for type in [DiaryType.memo, .alarm, .hospital, .shower, .pill, .abnormal] {
            let entries = diaryRepository.fetchByDateAndType(date: date, type: type)
            if !entries.isEmpty {
                result[type] = entries
            }
        }
        return result
    }

    package func executeFlat(date: Date) -> [DiaryEntry] {
        diaryRepository.fetchByDate(date)
    }
}
