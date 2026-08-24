import Foundation
import Testing
import Domain

@testable import BanGiDa

struct StoryTests {
    @Test func retainsFirestoreDocumentID() {
        let story = Story(
            id: "firestore-document-id",
            writerUID: "writer-uid",
            imageURL: "https://example.com/story.jpg",
            time: "방금 전",
            nickname: "닉네임",
            text: "스토리",
            isHearted: false,
            heartCount: 0,
            commentCount: 0,
            previewComments: []
        )

        #expect(story.id == "firestore-document-id")
    }

    @Test func mockStoryIDsAreUnique() {
        let ids = Story.mock.map(\.id)

        #expect(Set(ids).count == ids.count)
    }
}

struct FetchStoriesUseCaseTests {
    @Test func mapsPreviewsToTheirMatchingStoriesAndUsesEmptyPreviewsWhenAbsent() async throws {
        let storyRepository = MockStoryRepository()
        storyRepository.fetchedPage = StoryPage(
            stories: [makeStory(id: "story-a"), makeStory(id: "story-b"), makeStory(id: "story-c")],
            nextCursor: nil,
            isEnd: true
        )
        let commentRepository = MockCommentRepository()
        commentRepository.previewCommentsByStoryID = [
            "story-a": [makePreviewComment(id: "comment-a", storyID: "story-a")],
            "story-c": [makePreviewComment(id: "comment-c", storyID: "story-c")]
        ]

        let page = try await makeFetchStoriesUseCase(
            storyRepository: storyRepository,
            commentRepository: commentRepository
        )
        .execute(after: nil)

        #expect(page.stories[0].previewComments.map(\.id) == ["comment-a"])
        #expect(page.stories[1].previewComments.isEmpty)
        #expect(page.stories[2].previewComments.map(\.id) == ["comment-c"])
    }

    @Test func preservesStoryPageCursorAndEndState() async throws {
        let expectedCursor = StoryCursor(
            createdAt: Date(timeIntervalSince1970: 1_234),
            id: "next-story"
        )
        let storyRepository = MockStoryRepository()
        storyRepository.fetchedPage = StoryPage(
            stories: [makeStory(id: "story-a")],
            nextCursor: expectedCursor,
            isEnd: true
        )

        let page = try await makeFetchStoriesUseCase(
            storyRepository: storyRepository,
            commentRepository: MockCommentRepository()
        )
        .execute(after: nil)

        #expect(page.nextCursor == expectedCursor)
        #expect(page.isEnd)
    }

    @Test func requestsConfiguredPreviewLimitForAllFetchedStories() async throws {
        let storyRepository = MockStoryRepository()
        storyRepository.fetchedPage = StoryPage(
            stories: [makeStory(id: "story-a"), makeStory(id: "story-b")],
            nextCursor: nil,
            isEnd: true
        )
        let commentRepository = MockCommentRepository()

        _ = try await makeFetchStoriesUseCase(
            storyRepository: storyRepository,
            commentRepository: commentRepository
        )
        .execute(after: nil)

        #expect(commentRepository.requestedPreviewStoryIDs == ["story-a", "story-b"])
        #expect(commentRepository.requestedPreviewLimit == CommentPolicy.previewCount)
    }

    @Test func excludesStoriesAndPreviewCommentsFromBlockedUsersWhilePreservingPageMetadata() async throws {
        let expectedCursor = StoryCursor(createdAt: Date(timeIntervalSince1970: 5_678), id: "next-story")
        let storyRepository = MockStoryRepository()
        storyRepository.fetchedPage = StoryPage(
            stories: [
                makeStory(id: "story-a", writerUID: "blocked-writer"),
                makeStory(id: "story-b", writerUID: "writer-b")
            ],
            nextCursor: expectedCursor,
            isEnd: false
        )
        let commentRepository = MockCommentRepository()
        commentRepository.previewCommentsByStoryID = [
            "story-b": [
                makePreviewComment(id: "comment-blocked", storyID: "story-b", authorUID: "blocked-writer"),
                makePreviewComment(id: "comment-visible", storyID: "story-b", authorUID: "commenter-b")
            ]
        ]
        let userRepository = MockUserRepository()
        userRepository.uid = "test-user"
        userRepository.blockedUIDs = ["blocked-writer"]

        let page = try await makeFetchStoriesUseCase(
            storyRepository: storyRepository,
            commentRepository: commentRepository,
            userRepository: userRepository
        )
        .execute(after: nil)

        #expect(page.stories.map(\.id) == ["story-b"])
        #expect(page.stories[0].previewComments.map(\.id) == ["comment-visible"])
        // §5.2 불변식: 차단 필터로 스토리가 줄어도 isEnd/nextCursor는 storyRepository가 준
        // 원본 값 그대로여야 무한 스크롤이 조기 종료되지 않는다.
        #expect(page.nextCursor == expectedCursor)
        #expect(page.isEnd == false)
    }
}

private func makeFetchStoriesUseCase(
    storyRepository: MockStoryRepository,
    commentRepository: MockCommentRepository,
    userRepository: MockUserRepository? = nil
) -> FetchStoriesUseCaseImpl {
    let userRepository = userRepository ?? {
        let userRepository = MockUserRepository()
        userRepository.uid = "test-user"
        return userRepository
    }()

    return FetchStoriesUseCaseImpl(
        storyRepository: storyRepository,
        commentRepository: commentRepository,
        userRepository: userRepository
    )
}

private func makeStory(id: String, writerUID: String? = nil) -> Story {
    Story(
        id: id,
        writerUID: writerUID ?? "writer-\(id)",
        imageURL: "https://example.com/\(id).jpg",
        time: "방금 전",
        nickname: "닉네임",
        text: "스토리",
        isHearted: false,
        heartCount: 0,
        commentCount: 0,
        previewComments: []
    )
}

// Swift Testing에도 Comment 타입이 있어 이름이 겹치므로 모듈명을 명시한다.
private func makePreviewComment(id: String, storyID: String, authorUID: String? = nil) -> Domain.Comment {
    Domain.Comment(
        id: id,
        storyID: storyID,
        authorUID: authorUID ?? "author-\(id)",
        authorNickname: "댓글러",
        text: "댓글 내용",
        createdAt: Date(timeIntervalSince1970: 1_234),
        displayTime: "방금 전"
    )
}
