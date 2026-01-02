//
//  WriteStoryUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import Foundation

public protocol WriteStoryUseCase {
    func execute(image: Data, text: String) async throws
}

public final class WriteStoryUseCaseImpl: WriteStoryUseCase {
    private let storyRepository: StoryRepository
    private let userRepository: UserRepository
    
    public init(storyRepository: StoryRepository, userRepository: UserRepository) {
        self.storyRepository = storyRepository
        self.userRepository = userRepository
    }
    
    public func execute(image: Data, text: String) async throws {
        // 만약 UID가 없으면 익명 계정 생성 재시도
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }
        
        // 그래도 실패한다면 Error throw
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        guard let nickname = userRepository.readNickname() else { throw UserError.emptyNickname }
        
        try await storyRepository.writeStory(image: image, text: text, nickname: nickname, uid: uid)
    }
}
