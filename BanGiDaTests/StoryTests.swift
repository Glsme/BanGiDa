import Foundation
import Testing

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
}

private func makeFetchStoriesUseCase(
    storyRepository: MockStoryRepository,
    commentRepository: MockCommentRepository
) -> FetchStoriesUseCaseImpl {
    let userRepository = MockUserRepository()
    userRepository.uid = "test-user"

    return FetchStoriesUseCaseImpl(
        storyRepository: storyRepository,
        commentRepository: commentRepository,
        userRepository: userRepository
    )
}

private func makeStory(id: String) -> Story {
    Story(
        id: id,
        writerUID: "writer-\(id)",
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
private func makePreviewComment(id: String, storyID: String) -> BanGiDa.Comment {
    BanGiDa.Comment(
        id: id,
        storyID: storyID,
        authorUID: "author-\(id)",
        authorNickname: "댓글러",
        text: "댓글 내용",
        createdAt: Date(timeIntervalSince1970: 1_234),
        displayTime: "방금 전"
    )
}
