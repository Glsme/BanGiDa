//
//  BlockedUser.swift
//  BanGiDa
//

import Foundation

public struct BlockedUser: Identifiable, Hashable {
    public let id: String
    public let nickname: String
    public let blockedAt: Date
    public let displayTime: String

    public init(
        id: String,
        nickname: String,
        blockedAt: Date,
        displayTime: String
    ) {
        self.id = id
        self.nickname = nickname
        self.blockedAt = blockedAt
        self.displayTime = displayTime
    }
}
