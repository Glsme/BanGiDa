//
//  FetchCommentsUseCase.swift
//  BanGiDa
//

import Foundation

public protocol FetchCommentsUseCase {
    func execute(storyID: String, after cursor: CommentCursor?) async throws -> CommentPage
}

public final class FetchCommentsUseCaseImpl: FetchCommentsUseCase {
    private let commentRepository: CommentRepository
    private let userRepository: UserRepository

    public init(commentRepository: CommentRepository, userRepository: UserRepository) {
        self.commentRepository = commentRepository
        self.userRepository = userRepository
    }

    public func execute(storyID: String, after cursor: CommentCursor?) async throws -> CommentPage {
        let page = try await commentRepository.fetchComments(
            storyID: storyID,
            after: cursor,
            limit: CommentPolicy.pageSize
        )
        let blockedUIDs = try await userRepository.fetchBlockedUIDs()

        // FetchStoriesUseCase와 동일한 불변식: 필터 후 개수가 아니라 원본 isEnd/nextCursor를
        // 그대로 전달해 무한 스크롤이 조기 종료되지 않게 한다.
        let visibleComments = page.comments.filter { !blockedUIDs.contains($0.authorUID) }

        return CommentPage(comments: visibleComments, nextCursor: page.nextCursor, isEnd: page.isEnd)
    }
}
