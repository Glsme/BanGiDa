//
//  ReportTarget.swift
//  BanGiDa
//

import Foundation

/// 신고 대상을 일반화한 값. 스토리와 댓글 모두 같은 `ReportSheetView`/`ReportViewModel`을
/// 통해 신고할 수 있도록 두 경우를 하나의 타입으로 묶는다.
public enum ReportTarget: Hashable {
    case story(storyID: String)
    case comment(storyID: String, commentID: String)
}

public extension ReportTarget {
    package var storyID: String {
        switch self {
        case .story(let storyID):
            return storyID
        case .comment(let storyID, _):
            return storyID
        }
    }

    package var commentID: String? {
        switch self {
        case .story:
            return nil
        case .comment(_, let commentID):
            return commentID
        }
    }

    /// §8.6 최상위 `reports` 컬렉션의 `targetType` 필드 값.
    package var targetType: String {
        switch self {
        case .story:
            return "story"
        case .comment:
            return "comment"
        }
    }

    /// §8.6 최상위 `reports` 컬렉션의 `targetPath` 필드 값.
    package var targetPath: String {
        switch self {
        case .story(let storyID):
            return "images/\(storyID)"
        case .comment(let storyID, let commentID):
            return "images/\(storyID)/comments/\(commentID)"
        }
    }
}
