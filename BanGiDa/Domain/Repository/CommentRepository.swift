//
//  CommentRepository.swift
//  BanGiDa
//

import Foundation

public protocol CommentRepository {
    func fetchComments(storyID: String, after cursor: CommentCursor?, limit: Int) async throws -> CommentPage
    func writeComment(storyID: String, text: String, authorUID: String, authorNickname: String) async throws -> Comment
}
