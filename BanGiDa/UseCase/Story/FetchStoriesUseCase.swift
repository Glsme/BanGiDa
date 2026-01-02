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
    
    public init(storyRepository: StoryRepository) {
        self.storyRepository = storyRepository
    }
    
    public func execute(after cursor: StoryCursor?) async throws -> StoryPage {
        try await storyRepository.fetchStories(after: cursor)
    }
}
