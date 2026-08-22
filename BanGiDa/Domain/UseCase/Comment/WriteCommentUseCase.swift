//
//  WriteCommentUseCase.swift
//  BanGiDa
//

import Foundation

public protocol WriteCommentUseCase {
    func execute(storyID: String, text: String) async throws -> Comment
}

public final class WriteCommentUseCaseImpl: WriteCommentUseCase {
    private let commentRepository: CommentRepository
    private let userRepository: UserRepository
    private let profanityFilter: ProfanityFilter

    public init(
        commentRepository: CommentRepository,
        userRepository: UserRepository,
        profanityFilter: ProfanityFilter
    ) {
        self.commentRepository = commentRepository
        self.userRepository = userRepository
        self.profanityFilter = profanityFilter
    }

    public func execute(storyID: String, text: String) async throws -> Comment {
        if userRepository.loadUID()?.isEmpty ?? true {
            try await userRepository.createUser()
        }

        guard let uid = userRepository.loadUID() else { throw UserError.emptyUID }
        guard let nickname = userRepository.readNickname() else { throw UserError.emptyNickname }

        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { throw CommentError.emptyText }
        guard trimmedText.count <= CommentPolicy.maxLength else { throw CommentError.textTooLong }
        guard !profanityFilter.containsProhibitedWord(trimmedText) else {
            throw CommentError.containsProhibitedWord
        }

        return try await commentRepository.writeComment(
            storyID: storyID,
            text: trimmedText,
            authorUID: uid,
            authorNickname: nickname
        )
    }
}
