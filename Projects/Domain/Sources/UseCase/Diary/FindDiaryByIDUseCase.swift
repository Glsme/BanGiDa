//
//  FindDiaryByIDUseCase.swift
//  BanGiDa
//
//  Created by Claude on 4/16/26.
//

import Foundation

package protocol FindDiaryByIDUseCase {
    func execute(id: String) -> DiaryEntry?
}

package final class FindDiaryByIDUseCaseImpl: FindDiaryByIDUseCase {
    private let diaryRepository: DiaryRepository

    package init(diaryRepository: DiaryRepository) {
        self.diaryRepository = diaryRepository
    }

    package func execute(id: String) -> DiaryEntry? {
        diaryRepository.findByID(id)
    }
}
