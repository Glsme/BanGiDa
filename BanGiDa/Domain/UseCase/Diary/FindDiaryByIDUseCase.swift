//
//  FindDiaryByIDUseCase.swift
//  BanGiDa
//
//  Created by Claude on 4/16/26.
//

import Foundation

protocol FindDiaryByIDUseCase {
    func execute(id: String) -> DiaryEntry?
}

final class FindDiaryByIDUseCaseImpl: FindDiaryByIDUseCase {
    private let diaryRepository: DiaryRepository

    init(diaryRepository: DiaryRepository) {
        self.diaryRepository = diaryRepository
    }

    func execute(id: String) -> DiaryEntry? {
        diaryRepository.findByID(id)
    }
}
