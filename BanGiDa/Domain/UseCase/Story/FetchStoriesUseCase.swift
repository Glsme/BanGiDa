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
    private let commentRepository: CommentRepository
    private let userRepository: UserRepository
    
    public init(
        storyRepository: StoryRepository,
        commentRepository: CommentRepository,
        userRepository: UserRepository
    ) {
        self.storyRepository = storyRepository
        self.commentRepository = commentRepository
        self.userRepository = userRepository
    }
    
    public func execute(after cursor: StoryCursor?) async throws -> StoryPage {
        // 만약 UID가 없으면 익명 계정 생성 재시도
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }

        // 그래도 실패한다면 Error throw
        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }

        let page = try await storyRepository.fetchStories(after: cursor, uid: uid)
        let blockedUIDs = try await userRepository.fetchBlockedUIDs()

        // §5.2 주의: 차단 필터로 스토리가 걸러져도 isEnd/nextCursor는 storyRepository가 준
        // 원본 값을 그대로 전달한다. 필터 후 개수로 다시 판정하면 무한 스크롤이 조기 종료된다.
        let visibleStories = page.stories.filter { !blockedUIDs.contains($0.writerUID) }

        let previews = try await commentRepository.fetchPreviewComments(
            storyIDs: visibleStories.map(\.id),
            limit: CommentPolicy.previewCount
        )
        let merged = visibleStories.map { story -> Story in
            var story = story
            story.previewComments = (previews[story.id] ?? []).filter { !blockedUIDs.contains($0.authorUID) }
            return story
        }

        return StoryPage(stories: merged, nextCursor: page.nextCursor, isEnd: page.isEnd)
    }
}
