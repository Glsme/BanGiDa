//
//  FetchStoriesUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import Foundation

public protocol FetchStoriesUseCase {
    func execute(after cursor: StoryCursor?) async throws -> StoryPage
}

public final class FetchStoriesUseCaseImpl: FetchStoriesUseCase {
    private let storyRepository: StoryRepository
    private let userRepository: UserRepository
    
    public init(storyRepository: StoryRepository, userRepository: UserRepository) {
        self.storyRepository = storyRepository
        self.userRepository = userRepository
    }
    
    public func execute(after cursor: StoryCursor?) async throws -> StoryPage {
        // 만약 UID가 없으면 익명 계정 생성 재시도
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }
        
        // 그래도 실패한다면 Error throw
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        
        return try await storyRepository.fetchStories(after: cursor, uid: uid)
    }
}
