import Foundation

@testable import BanGiDa

final class MockProfanityFilter: ProfanityFilter {
    var isProhibited = false
    var prohibitedTexts: Set<String> = []

    private(set) var checkedTexts: [String] = []

    func containsProhibitedWord(_ text: String) -> Bool {
        checkedTexts.append(text)
        return isProhibited || prohibitedTexts.contains(text)
    }
}

final class MockCommentRepository: CommentRepository {
    var fetchedPage = CommentPage(comments: [], nextCursor: nil, isEnd: true)
    var previewCommentsByStoryID: [String: [Comment]] = [:]
    var fetchError: Error?
    var previewFetchError: Error?
    var writeError: Error?
    var deleteError: Error?
    var reportError: Error?
    var writtenComment = Comment(
        id: "written-comment",
        storyID: "story-id",
        authorUID: "author-uid",
        authorNickname: "작성자",
        text: "댓글",
        createdAt: Date(),
        displayTime: "방금 전"
    )

    private(set) var requestedStoryID: String?
    private(set) var requestedCursor: CommentCursor?
    private(set) var requestedLimit: Int?
    private(set) var requestedPreviewStoryIDs: [String] = []
    private(set) var requestedPreviewLimit: Int?
    private(set) var writtenStoryID: String?
    private(set) var writtenText: String?
    private(set) var writtenAuthorUID: String?
    private(set) var writtenAuthorNickname: String?
    private(set) var deletedStoryID: String?
    private(set) var deletedCommentID: String?
    private(set) var reportedStoryID: String?
    private(set) var reportedCommentID: String?
    private(set) var reportedReporterUID: String?
    private(set) var reportedTargetAuthorUID: String?
    private(set) var reportedContentSnapshot: String?
    private(set) var reportedReason: String?

    func fetchComments(
        storyID: String,
        after cursor: CommentCursor?,
        limit: Int
    ) async throws -> CommentPage {
        requestedStoryID = storyID
        requestedCursor = cursor
        requestedLimit = limit

        if let fetchError {
            throw fetchError
        }

        return fetchedPage
    }

    func fetchPreviewComments(
        storyIDs: [String],
        limit: Int
    ) async throws -> [String: [Comment]] {
        requestedPreviewStoryIDs = storyIDs
        requestedPreviewLimit = limit

        if let previewFetchError {
            throw previewFetchError
        }

        return previewCommentsByStoryID
    }

    func writeComment(
        storyID: String,
        text: String,
        authorUID: String,
        authorNickname: String
    ) async throws -> Comment {
        writtenStoryID = storyID
        writtenText = text
        writtenAuthorUID = authorUID
        writtenAuthorNickname = authorNickname

        if let writeError {
            throw writeError
        }

        return writtenComment
    }

    func deleteComment(storyID: String, commentID: String) async throws {
        deletedStoryID = storyID
        deletedCommentID = commentID

        if let deleteError {
            throw deleteError
        }
    }

    func reportComment(
        storyID: String,
        commentID: String,
        reporterUID: String,
        targetAuthorUID: String,
        contentSnapshot: String,
        reason: String
    ) async throws {
        reportedStoryID = storyID
        reportedCommentID = commentID
        reportedReporterUID = reporterUID
        reportedTargetAuthorUID = targetAuthorUID
        reportedContentSnapshot = contentSnapshot
        reportedReason = reason

        if let reportError {
            throw reportError
        }
    }
}

final class MockStoryRepository: StoryRepository {
    var fetchedPage = StoryPage(stories: [], nextCursor: nil, isEnd: true)
    var fetchError: Error?

    private(set) var requestedCursor: StoryCursor?
    private(set) var requestedUID: String?

    func fetchStories(after cursor: StoryCursor?, uid: String) async throws -> StoryPage {
        requestedCursor = cursor
        requestedUID = uid

        if let fetchError {
            throw fetchError
        }

        return fetchedPage
    }

    func writeStory(image: Data, text: String, nickname: String, uid: String) async throws {}

    func toggleLike(storyID: String, uid: String) async throws {}

    private(set) var reportedTargetAuthorUID: String?
    private(set) var reportedContentSnapshot: String?

    func report(
        storyID: String,
        uid: String,
        reason: String,
        targetAuthorUID: String,
        contentSnapshot: String
    ) async throws {
        reportedTargetAuthorUID = targetAuthorUID
        reportedContentSnapshot = contentSnapshot
    }
}

final class MockUserRepository: UserRepository {
    var uid: String?
    var uidAfterCreate: String?
    var nickname: String?
    var blockedUIDs: Set<String> = []
    var fetchBlockedUIDsError: Error?
    var blockedUsers: [BlockedUser] = []
    var fetchBlockedUsersError: Error?
    var unblockError: Error?
    var commentNotificationEnabled = true
    var fetchCommentNotificationEnabledError: Error?
    var updateCommentNotificationEnabledError: Error?

    private(set) var createUserCallCount = 0
    private(set) var blockedUID: String?
    private(set) var blockedNickname: String?
    private(set) var unblockedUID: String?
    private(set) var updatedFCMTokens: [String] = []
    private(set) var updatedCommentNotificationEnabledValues: [Bool] = []

    func signIn() async throws {}

    func createUser() async throws {
        createUserCallCount += 1
        uid = uidAfterCreate
    }

    func updateLastSeenAt() async throws {}

    func update(nickname: String) async throws {
        self.nickname = nickname
    }

    func updateFCMToken(_ token: String) async throws {
        updatedFCMTokens.append(token)
    }

    func updateCommentNotificationEnabled(_ isEnabled: Bool) async throws {
        if let updateCommentNotificationEnabledError {
            throw updateCommentNotificationEnabledError
        }

        commentNotificationEnabled = isEnabled
        updatedCommentNotificationEnabledValues.append(isEnabled)
    }

    func fetchCommentNotificationEnabled() async throws -> Bool {
        if let fetchCommentNotificationEnabledError {
            throw fetchCommentNotificationEnabledError
        }

        return commentNotificationEnabled
    }

    func readNickname() -> String? {
        nickname
    }

    func checkRegistration(uid: String) async throws -> Bool {
        true
    }

    func loadUID() -> String? {
        uid
    }

    func fetchBlockedUIDs() async throws -> Set<String> {
        if let fetchBlockedUIDsError {
            throw fetchBlockedUIDsError
        }

        return blockedUIDs
    }

    func fetchBlockedUsers() async throws -> [BlockedUser] {
        if let fetchBlockedUsersError {
            throw fetchBlockedUsersError
        }

        return blockedUsers
    }

    func block(uid: String, nickname: String) async throws {
        blockedUID = uid
        blockedNickname = nickname
        blockedUIDs.insert(uid)
        blockedUsers.append(
            BlockedUser(
                id: uid,
                nickname: nickname,
                blockedAt: Date(),
                displayTime: "방금 전"
            )
        )
    }

    func unblock(uid: String) async throws {
        if let unblockError {
            throw unblockError
        }

        unblockedUID = uid
        blockedUIDs.remove(uid)
        blockedUsers.removeAll { $0.id == uid }
    }
}

final class MockAnalyticsRepository: AnalyticsRepository {
    private(set) var recordedErrors: [Error] = []

    func logEvent(_ name: String, parameters: [String: Any]?) {}

    func recordError(_ error: Error, userInfo: [String: Any]?) {
        recordedErrors.append(error)
    }
}

final class MockResetDataUseCase: ResetDataUseCase {
    func execute() throws {}
}

final class MockRestoreNotificationsUseCase: RestoreNotificationsUseCase {
    func execute() {}
}

final class MockUserPreferencesUseCase: UserPreferencesUseCase {
    func getPetName() -> String? { nil }

    func setPetName(_ name: String) {}

    func isFirstLaunchCompleted() -> Bool { false }

    func setFirstLaunchCompleted() {}
}

enum TestCommentError: Error {
    case networkFailure
}
