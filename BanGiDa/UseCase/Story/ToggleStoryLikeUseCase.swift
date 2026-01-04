//
//  ToggleStoryLikeUseCase.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/3/26.
//

import Foundation

public protocol ToggleStoryLikeUseCase {
    func execute(imageURL: String) async throws
}

public final class ToggleStoryLikeUseCaseImpl: ToggleStoryLikeUseCase {
    private let storyRepository: StoryRepository
    private let userRepository: UserRepository
    
    public init(storyRepository: StoryRepository, userRepository: UserRepository) {
        self.storyRepository = storyRepository
        self.userRepository = userRepository
    }
    
    public func execute(imageURL: String) async throws {
        // 만약 UID가 없으면 익명 계정 생성 재시도
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }
        
        // 그래도 실패한다면 Error throw
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        guard let imageURL = URL(string: imageURL) else { throw WriteStoryError.emptyURL }
        
        let imageID = cacheKey(for: imageURL)
        try await storyRepository.toggleLike(imageID: imageID, uid: uid)
    }
    
    // MARK: - Private
    
    private func cacheKey(for url: URL) -> String {
        let absolute = url.absoluteString
        guard let range = absolute.range(of: "images%2F") else {
            return url.absoluteString
        }

        let idStart = range.upperBound
        let remaining = absolute[idStart...]
        let uid = remaining.split(separator: "?").first.map(String.init) ?? url.absoluteString
        return uid.isEmpty ? url.absoluteString : uid
    }
}
