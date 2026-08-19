//
//  CommentTypes.swift
//  BanGiDa
//

import Foundation

public struct Comment: Identifiable, Hashable {
    public let id: String
    public let storyID: String
    public let authorUID: String
    public let authorNickname: String
    public let text: String
    public let createdAt: Date
    public let displayTime: String

    public init(
        id: String,
        storyID: String,
        authorUID: String,
        authorNickname: String,
        text: String,
        createdAt: Date,
        displayTime: String
    ) {
        self.id = id
        self.storyID = storyID
        self.authorUID = authorUID
        self.authorNickname = authorNickname
        self.text = text
        self.createdAt = createdAt
        self.displayTime = displayTime
    }
}

public struct CommentPage {
    public let comments: [Comment]
    public let nextCursor: CommentCursor?
    public let isEnd: Bool

    public init(comments: [Comment], nextCursor: CommentCursor?, isEnd: Bool) {
        self.comments = comments
        self.nextCursor = nextCursor
        self.isEnd = isEnd
    }
}

public struct CommentCursor: Hashable, Codable {
    public let createdAt: Date
    public let id: String

    public init(createdAt: Date, id: String) {
        self.createdAt = createdAt
        self.id = id
    }
}
