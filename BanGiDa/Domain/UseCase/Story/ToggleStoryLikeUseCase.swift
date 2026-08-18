//
//  ToggleStoryLikeUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/3/26.
//

import Foundation

public protocol ToggleStoryLikeUseCase {
    func execute(storyID: String) async throws
}

public final class ToggleStoryLikeUseCaseImpl: ToggleStoryLikeUseCase {
    private let storyRepository: StoryRepository
    private let userRepository: UserRepository
    
    public init(storyRepository: StoryRepository, userRepository: UserRepository) {
        self.storyRepository = storyRepository
        self.userRepository = userRepository
    }
    
    public func execute(storyID: String) async throws {
        // 만약 UID가 없으면 익명 계정 생성 재시도
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }
        
        // 그래도 실패한다면 Error throw
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        try await storyRepository.toggleLike(storyID: storyID, uid: uid)
    }
}
