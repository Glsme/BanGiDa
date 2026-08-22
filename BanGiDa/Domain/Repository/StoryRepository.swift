//
//  StoryRepository.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/2/26.
//

import Foundation

public protocol StoryRepository {
    func fetchStories(after cursor: StoryCursor?, uid: String) async throws -> StoryPage
    func writeStory(image: Data, text: String, nickname: String, uid: String) async throws
    func toggleLike(storyID: String, uid: String) async throws
    func report(
        storyID: String,
        uid: String,
        reason: String,
        targetAuthorUID: String,
        contentSnapshot: String
    ) async throws
}
