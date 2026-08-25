//
//  DeleteCommentUseCase.swift
//  BanGiDa
//

import Foundation

public protocol DeleteCommentUseCase {
    func execute(comment: Comment) async throws
}

public final class DeleteCommentUseCaseImpl: DeleteCommentUseCase {
    private let commentRepository: CommentRepository
    private let userRepository: UserRepository

    public init(commentRepository: CommentRepository, userRepository: UserRepository) {
        self.commentRepository = commentRepository
        self.userRepository = userRepository
    }

    public func execute(comment: Comment) async throws {
        // 기존 WriteCommentUseCase와 동일한 UID 확보 절차.
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }

        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        // D5: 본인 댓글만 삭제할 수 있다. 스토리 작성자에게도 타인 댓글 삭제 권한은 없다.
        guard comment.authorUID == uid else { throw CommentError.notAuthor }

        try await commentRepository.deleteComment(storyID: comment.storyID, commentID: comment.id)
    }
}
