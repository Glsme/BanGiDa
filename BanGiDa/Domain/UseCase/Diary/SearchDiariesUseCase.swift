//
//  SearchDiariesUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol SearchDiariesUseCase {
    func execute(type: DiaryType) -> [DiaryEntry]
    func executeAll() -> [DiaryEntry]
}

final class SearchDiariesUseCaseImpl: SearchDiariesUseCase {
    private let diaryRepository: DiaryRepository

    init(diaryRepository: DiaryRepository) {
        self.diaryRepository = diaryRepository
    }

    func execute(type: DiaryType) -> [DiaryEntry] {
        diaryRepository.fetchByType(type)
    }

    func executeAll() -> [DiaryEntry] {
        diaryRepository.fetchAll()
    }
}
