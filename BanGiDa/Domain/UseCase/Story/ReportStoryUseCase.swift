//
//  ReportStoryUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/4/26.
//

import Foundation

public protocol ReportStoryUseCase {
    func execute(storyID: String, reason: String) async throws
}

public final class ReportStoryUseCaseImpl: ReportStoryUseCase {
    private let storyRepository: StoryRepository
    private let userRepository: UserRepository
    
    public init(storyRepository: StoryRepository, userRepository: UserRepository) {
        self.storyRepository = storyRepository
        self.userRepository = userRepository
    }
    
    public func execute(storyID: String, reason: String) async throws {
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        try await storyRepository.report(storyID: storyID, uid: uid, reason: reason)
    }
}
