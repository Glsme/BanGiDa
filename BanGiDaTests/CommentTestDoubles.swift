import Foundation

@testable import BanGiDa

final class MockCommentRepository: CommentRepository {
    var fetchedPage = CommentPage(comments: [], nextCursor: nil, isEnd: true)
    var previewCommentsByStoryID: [String: [Comment]] = [:]
    var fetchError: Error?
    var previewFetchError: Error?
    var writeError: Error?
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

    func report(storyID: String, uid: String, reason: String) async throws {}
}

final class MockUserRepository: UserRepository {
    var uid: String?
    var uidAfterCreate: String?
    var nickname: String?

    private(set) var createUserCallCount = 0

    func signIn() async throws {}

    func createUser() async throws {
        createUserCallCount += 1
        uid = uidAfterCreate
    }

    func updateLastSeenAt() async throws {}

    func update(nickname: String) async throws {
        self.nickname = nickname
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
}

final class MockAnalyticsRepository: AnalyticsRepository {
    private(set) var recordedErrors: [Error] = []

    func logEvent(_ name: String, parameters: [String: Any]?) {}

    func recordError(_ error: Error, userInfo: [String: Any]?) {
        recordedErrors.append(error)
    }
}

enum TestCommentError: Error {
    case networkFailure
}
