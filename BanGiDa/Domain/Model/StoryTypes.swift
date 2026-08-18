//
//  StoryTypes.swift
//  BanGiDa
//
//  Created by 홍석준 on 1/??/25.
//

import Foundation

public struct Story: Identifiable {
    public let id: String
    public let writerUID: String
    public let imageURL: String
    public let time: String
    public let nickname: String
    public let text: String
    public var isHearted: Bool
    public var heartCount: Int
}

public struct StoryPage {
    public let stories: [Story]
    public let nextCursor: StoryCursor?
    public let isEnd: Bool

    public init(stories: [Story], nextCursor: StoryCursor?, isEnd: Bool) {
        self.stories = stories
        self.nextCursor = nextCursor
        self.isEnd = isEnd
    }
}

public struct StoryCursor: Hashable, Codable {
    public let createdAt: Date
    public let id: String

    public init(createdAt: Date, id: String) {
        self.createdAt = createdAt
        self.id = id
    }
}

public extension StoryCursor {
    static let initialTopStoriesCursorID = "__INITIAL_TOP_STORIES__"

    static func initialTopStories() -> StoryCursor {
        StoryCursor(createdAt: .distantPast, id: initialTopStoriesCursorID)
    }

    var isInitialTopStories: Bool {
        id == Self.initialTopStoriesCursorID
    }
}
