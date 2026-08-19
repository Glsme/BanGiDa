import Foundation
import Testing

@testable import BanGiDa

struct WriteCommentUseCaseTests {
    @Test func rejectsWhitespaceOnlyText() async {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        userRepository.uid = "uid"
        userRepository.nickname = "닉네임"
        let useCase = WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )

        await #expect(throws: CommentError.emptyText) {
            try await useCase.execute(storyID: "story-id", text: " \n ")
        }
    }

    @Test func rejectsTextLongerThanMaximumLength() async {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        userRepository.uid = "uid"
        userRepository.nickname = "닉네임"
        let useCase = WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )

        await #expect(throws: CommentError.textTooLong) {
            try await useCase.execute(
                storyID: "story-id",
                text: String(repeating: "가", count: CommentPolicy.maxLength + 1)
            )
        }
    }

    @Test func trimsTextBeforeWritingToRepository() async throws {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        userRepository.uid = "uid"
        userRepository.nickname = "닉네임"
        let useCase = WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )

        _ = try await useCase.execute(storyID: "story-id", text: "  반가워요! \n")

        #expect(commentRepository.writtenText == "반가워요!")
        #expect(commentRepository.writtenStoryID == "story-id")
    }

    @Test func createsUserBeforeWritingWhenUIDIsMissing() async throws {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        userRepository.uidAfterCreate = "new-uid"
        userRepository.nickname = "닉네임"
        let useCase = WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )

        _ = try await useCase.execute(storyID: "story-id", text: "댓글")

        #expect(userRepository.createUserCallCount == 1)
        #expect(commentRepository.writtenAuthorUID == "new-uid")
    }
}

@Suite(.serialized)
struct CommentViewModelTests {
    @MainActor
    @Test func retainsInputTextWhenSendingFails() async {
        let commentRepository = MockCommentRepository()
        commentRepository.writeError = TestCommentError.networkFailure
        let viewModel = makeViewModel(commentRepository: commentRepository)
        viewModel.inputText = "다시 시도할 댓글"

        viewModel.send()
        await waitUntil { viewModel.errorMessage != nil }

        #expect(viewModel.inputText == "다시 시도할 댓글")
        #expect(!viewModel.isSending)
    }

    @MainActor
    @Test func insertsSuccessfulCommentAtFrontOfNewestFirstList() async {
        let commentRepository = MockCommentRepository()
        let existingComment = makeComment(id: "existing-comment", authorUID: "other-uid")
        commentRepository.fetchedPage = CommentPage(
            comments: [existingComment],
            nextCursor: nil,
            isEnd: true
        )
        commentRepository.writtenComment = makeComment(id: "new-comment", authorUID: "writer-uid")
        let viewModel = makeViewModel(commentRepository: commentRepository)
        viewModel.comments = [existingComment]
        viewModel.inputText = "새 댓글"

        viewModel.send()
        await waitUntil { viewModel.comments.first?.id == "new-comment" }

        #expect(viewModel.comments.map(\.id) == ["new-comment", "existing-comment"])
        #expect(viewModel.inputText.isEmpty)
    }

    @MainActor
    @Test func identifiesOnlyTheStoryWritersComments() {
        let viewModel = makeViewModel(commentRepository: MockCommentRepository())

        #expect(viewModel.isStoryAuthor(makeComment(id: "writer", authorUID: "writer-uid")))
        #expect(!viewModel.isStoryAuthor(makeComment(id: "visitor", authorUID: "visitor-uid")))
    }
}

@MainActor
private func makeViewModel(commentRepository: MockCommentRepository) -> CommentViewModel {
    let userRepository = MockUserRepository()
    userRepository.uid = "commenter-uid"
    userRepository.nickname = "댓글러"
    let analyticsRepository = MockAnalyticsRepository()

    AppDIContainer.shared.container.register(FetchCommentsUseCase.self) { _ in
        FetchCommentsUseCaseImpl(commentRepository: commentRepository)
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(WriteCommentUseCase.self) { _ in
        WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(AnalyticsRepository.self) { _ in
        analyticsRepository
    }
    .inObjectScope(.transient)

    return CommentViewModel(storyID: "story-id", storyWriterUID: "writer-uid")
}

@MainActor
// Swift Testing에도 Comment 타입이 있어 이름이 겹치므로 모듈명을 명시한다.
private func makeComment(id: String, authorUID: String) -> BanGiDa.Comment {
    BanGiDa.Comment(
        id: id,
        storyID: "story-id",
        authorUID: authorUID,
        authorNickname: "닉네임",
        text: "댓글 내용",
        createdAt: Date(),
        displayTime: "방금 전"
    )
}

@MainActor
private func waitUntil(_ condition: @escaping @MainActor () -> Bool) async {
    for _ in 0..<500 {
        if condition() {
            return
        }

        await Task.yield()
    }
}
