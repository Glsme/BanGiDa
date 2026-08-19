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

    public init(commentRepository: CommentRepository) {
        self.commentRepository = commentRepository
    }

    public func execute(storyID: String, after cursor: CommentCursor?) async throws -> CommentPage {
        try await commentRepository.fetchComments(
            storyID: storyID,
            after: cursor,
            limit: CommentPolicy.pageSize
        )
    }
}
