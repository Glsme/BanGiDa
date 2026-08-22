//
//  CommentError.swift
//  BanGiDa
//

import Foundation

public enum CommentError: Error, Equatable {
    case emptyText
    case textTooLong
    case rateLimited
    case notAuthor
}

public enum CommentPolicy {
    public static let maxLength = 300
    public static let previewCount = 2
    public static let pageSize = 20
    public static let writeCooldown: TimeInterval = 3
}
