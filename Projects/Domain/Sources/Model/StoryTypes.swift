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
    public var commentCount: Int
    public var previewComments: [Comment]

    // 멤버와이즈 이니셜라이저는 접근 수준이 internal을 넘지 못해
    // 모듈 밖에서 생성할 수 없다. 명시적으로 노출한다.
    public init(
        id: String,
        writerUID: String,
        imageURL: String,
        time: String,
        nickname: String,
        text: String,
        isHearted: Bool,
        heartCount: Int,
        commentCount: Int,
        previewComments: [Comment]
    ) {
        self.id = id
        self.writerUID = writerUID
        self.imageURL = imageURL
        self.time = time
        self.nickname = nickname
        self.text = text
        self.isHearted = isHearted
        self.heartCount = heartCount
        self.commentCount = commentCount
        self.previewComments = previewComments
    }
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
    package static let initialTopStoriesCursorID = "__INITIAL_TOP_STORIES__"

    package static func initialTopStories() -> StoryCursor {
        StoryCursor(createdAt: .distantPast, id: initialTopStoriesCursorID)
    }

    package var isInitialTopStories: Bool {
        id == Self.initialTopStoriesCursorID
    }
}
