//
//  SearchDiariesUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

package protocol SearchDiariesUseCase {
    func execute(type: DiaryType) -> [DiaryEntry]
    func executeAll() -> [DiaryEntry]
}

package final class SearchDiariesUseCaseImpl: SearchDiariesUseCase {
    private let diaryRepository: DiaryRepository

    package init(diaryRepository: DiaryRepository) {
        self.diaryRepository = diaryRepository
    }

    package func execute(type: DiaryType) -> [DiaryEntry] {
        diaryRepository.fetchByType(type)
    }

    package func executeAll() -> [DiaryEntry] {
        diaryRepository.fetchAll()
    }
}
