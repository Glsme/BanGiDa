//
//  ReportCommentUseCase.swift
//  BanGiDa
//

import Foundation

public protocol ReportCommentUseCase {
    func execute(
        storyID: String,
        commentID: String,
        targetAuthorUID: String,
        contentSnapshot: String,
        reason: String
    ) async throws
}

public final class ReportCommentUseCaseImpl: ReportCommentUseCase {
    private let commentRepository: CommentRepository
    private let userRepository: UserRepository

    public init(commentRepository: CommentRepository, userRepository: UserRepository) {
        self.commentRepository = commentRepository
        self.userRepository = userRepository
    }

    public func execute(
        storyID: String,
        commentID: String,
        targetAuthorUID: String,
        contentSnapshot: String,
        reason: String
    ) async throws {
        // 기존 WriteCommentUseCase와 동일한 UID 확보 절차.
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }

        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }

        // §8.6(D11): 댓글은 하드 삭제이므로 신고 시점의 원문(contentSnapshot)과 작성자
        // (targetAuthorUID)를 최상위 reports 컬렉션에 남겨 삭제 후에도 신고 이력이 보존되게 한다.
        try await commentRepository.reportComment(
            storyID: storyID,
            commentID: commentID,
            reporterUID: uid,
            targetAuthorUID: targetAuthorUID,
            contentSnapshot: contentSnapshot,
            reason: reason
        )
    }
}
