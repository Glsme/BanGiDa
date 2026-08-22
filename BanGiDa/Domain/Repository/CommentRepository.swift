//
//  CommentRepository.swift
//  BanGiDa
//

import Foundation

public protocol CommentRepository {
    func fetchComments(storyID: String, after cursor: CommentCursor?, limit: Int) async throws -> CommentPage
    func fetchPreviewComments(storyIDs: [String], limit: Int) async throws -> [String: [Comment]]
    func writeComment(storyID: String, text: String, authorUID: String, authorNickname: String) async throws -> Comment
    func deleteComment(storyID: String, commentID: String) async throws
    func reportComment(
        storyID: String,
        commentID: String,
        reporterUID: String,
        targetAuthorUID: String,
        contentSnapshot: String,
        reason: String
    ) async throws
}
