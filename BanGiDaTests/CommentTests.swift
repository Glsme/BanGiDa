import Foundation
import Testing
import Domain

@testable import BanGiDa

struct WriteCommentUseCaseTests {
    @Test func rejectsWhitespaceOnlyText() async {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        userRepository.uid = "uid"
        userRepository.nickname = "닉네임"
        let useCase = WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository,
            profanityFilter: MockProfanityFilter()
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
            userRepository: userRepository,
            profanityFilter: MockProfanityFilter()
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
            userRepository: userRepository,
            profanityFilter: MockProfanityFilter()
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
            userRepository: userRepository,
            profanityFilter: MockProfanityFilter()
        )

        _ = try await useCase.execute(storyID: "story-id", text: "댓글")

        #expect(userRepository.createUserCallCount == 1)
        #expect(commentRepository.writtenAuthorUID == "new-uid")
    }

    @Test func rejectsProhibitedTextBeforeWritingToRepository() async {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        let profanityFilter = MockProfanityFilter()
        userRepository.uid = "uid"
        userRepository.nickname = "닉네임"
        profanityFilter.prohibitedTexts = ["금칙어가 있는 댓글"]
        let useCase = WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository,
            profanityFilter: profanityFilter
        )

        await #expect(throws: CommentError.containsProhibitedWord) {
            try await useCase.execute(storyID: "story-id", text: "금칙어가 있는 댓글")
        }

        #expect(profanityFilter.checkedTexts == ["금칙어가 있는 댓글"])
        #expect(commentRepository.writtenStoryID == nil)
    }

    @Test func validatesEmptyTextThenLengthThenProhibitedText() async {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        let profanityFilter = MockProfanityFilter()
        userRepository.uid = "uid"
        userRepository.nickname = "닉네임"
        profanityFilter.isProhibited = true
        let useCase = WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository,
            profanityFilter: profanityFilter
        )

        await #expect(throws: CommentError.emptyText) {
            try await useCase.execute(storyID: "story-id", text: " \n ")
        }
        await #expect(throws: CommentError.textTooLong) {
            try await useCase.execute(
                storyID: "story-id",
                text: String(repeating: "가", count: CommentPolicy.maxLength + 1)
            )
        }
        await #expect(throws: CommentError.containsProhibitedWord) {
            try await useCase.execute(storyID: "story-id", text: "검사 대상 댓글")
        }

        #expect(profanityFilter.checkedTexts == ["검사 대상 댓글"])
        #expect(commentRepository.writtenStoryID == nil)
    }
}

struct FetchCommentsUseCaseTests {
    @Test func excludesCommentsFromBlockedUsersWhilePreservingPageMetadata() async throws {
        let expectedCursor = CommentCursor(createdAt: Date(timeIntervalSince1970: 42), id: "next-comment")
        let commentRepository = MockCommentRepository()
        commentRepository.fetchedPage = CommentPage(
            comments: [
                await makeComment(id: "comment-a", authorUID: "blocked-uid"),
                await makeComment(id: "comment-b", authorUID: "visible-uid")
            ],
            nextCursor: expectedCursor,
            isEnd: false
        )
        let userRepository = MockUserRepository()
        userRepository.uid = "reader-uid"
        userRepository.blockedUIDs = ["blocked-uid"]

        let useCase = FetchCommentsUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )

        let page = try await useCase.execute(storyID: "story-id", after: nil)

        #expect(page.comments.map(\.id) == ["comment-b"])
        // FetchStoriesUseCase와 동일한 불변식: 필터 후 개수가 아니라 원본 페이지 메타데이터를 유지한다.
        #expect(page.nextCursor == expectedCursor)
        #expect(page.isEnd == false)
    }
}

struct DeleteCommentUseCaseTests {
    @Test func rejectsDeletingSomeoneElsesComment() async {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        userRepository.uid = "commenter-uid"
        let useCase = DeleteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )
        let othersComment = await makeComment(id: "comment-id", authorUID: "someone-else-uid")

        await #expect(throws: CommentError.notAuthor) {
            try await useCase.execute(comment: othersComment)
        }
        #expect(commentRepository.deletedCommentID == nil)
    }

    @Test func deletesOwnCommentThroughRepository() async throws {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        userRepository.uid = "commenter-uid"
        let useCase = DeleteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )
        let ownComment = await makeComment(id: "comment-id", authorUID: "commenter-uid")

        try await useCase.execute(comment: ownComment)

        #expect(commentRepository.deletedStoryID == "story-id")
        #expect(commentRepository.deletedCommentID == "comment-id")
    }
}

struct ReportCommentUseCaseTests {
    @Test func forwardsContentSnapshotAndTargetAuthorUIDToRepository() async throws {
        let commentRepository = MockCommentRepository()
        let userRepository = MockUserRepository()
        userRepository.uid = "reporter-uid"
        let useCase = ReportCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )
        try await useCase.execute(
            storyID: "story-id",
            commentID: "comment-id",
            targetAuthorUID: "author-uid",
            contentSnapshot: "댓글 내용",
            reason: "부적절한 표현"
        )

        #expect(commentRepository.reportedStoryID == "story-id")
        #expect(commentRepository.reportedCommentID == "comment-id")
        #expect(commentRepository.reportedReporterUID == "reporter-uid")
        #expect(commentRepository.reportedTargetAuthorUID == "author-uid")
        #expect(commentRepository.reportedContentSnapshot == "댓글 내용")
        #expect(commentRepository.reportedReason == "부적절한 표현")
    }
}

struct BlockUserUseCaseTests {
    @Test func forwardsTargetUIDAndNicknameToRepository() async throws {
        let userRepository = MockUserRepository()
        userRepository.uid = "my-uid"
        let useCase = BlockUserUseCaseImpl(userRepository: userRepository)

        try await useCase.execute(targetUID: "target-uid", nickname: "차단 대상")

        #expect(userRepository.blockedUID == "target-uid")
        #expect(userRepository.blockedNickname == "차단 대상")
        #expect(userRepository.blockedUIDs.contains("target-uid"))
    }

    @Test func createsUserBeforeBlockingWhenUIDIsMissing() async throws {
        let userRepository = MockUserRepository()
        userRepository.uidAfterCreate = "new-uid"
        let useCase = BlockUserUseCaseImpl(userRepository: userRepository)

        try await useCase.execute(targetUID: "target-uid", nickname: "차단 대상")

        #expect(userRepository.createUserCallCount == 1)
        #expect(userRepository.blockedUID == "target-uid")
        #expect(userRepository.blockedNickname == "차단 대상")
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
    @Test func showsProhibitedWordMessageWithoutClearingInput() async {
        let commentRepository = MockCommentRepository()
        let profanityFilter = MockProfanityFilter()
        profanityFilter.isProhibited = true
        let viewModel = makeViewModel(
            commentRepository: commentRepository,
            profanityFilter: profanityFilter
        )
        viewModel.inputText = "금칙어 포함 댓글"

        viewModel.send()
        await waitUntil { viewModel.errorMessage != nil }

        #expect(viewModel.errorMessage == "사용할 수 없는 표현이 포함되어 있어요")
        #expect(viewModel.inputText == "금칙어 포함 댓글")
        #expect(commentRepository.writtenStoryID == nil)
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
    @Test func doesNotSendWhenInputIsOnlyWhitespace() async {
        let commentRepository = MockCommentRepository()
        let viewModel = makeViewModel(commentRepository: commentRepository)
        viewModel.inputText = "   \n\n  "

        viewModel.send()
        await Task.yield()

        // 전송 시도 자체가 없어야 한다. UseCase까지 가면 불필요한 오류 알럿이 뜬다.
        #expect(commentRepository.writtenText == nil)
        #expect(viewModel.errorMessage == nil)
        #expect(viewModel.inputText == "   \n\n  ")
    }

    @MainActor
    @Test func identifiesOnlyTheStoryWritersComments() {
        let viewModel = makeViewModel(commentRepository: MockCommentRepository())

        #expect(viewModel.isStoryAuthor(makeComment(id: "writer", authorUID: "writer-uid")))
        #expect(!viewModel.isStoryAuthor(makeComment(id: "visitor", authorUID: "visitor-uid")))
    }
}

@MainActor
private func makeViewModel(
    commentRepository: MockCommentRepository,
    profanityFilter: MockProfanityFilter = MockProfanityFilter()
) -> CommentViewModel {
    let userRepository = MockUserRepository()
    userRepository.uid = "commenter-uid"
    userRepository.nickname = "댓글러"
    let analyticsRepository = MockAnalyticsRepository()

    AppDIContainer.shared.container.register(FetchCommentsUseCase.self) { _ in
        FetchCommentsUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(WriteCommentUseCase.self) { _ in
        WriteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository,
            profanityFilter: profanityFilter
        )
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(DeleteCommentUseCase.self) { _ in
        DeleteCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(ReportCommentUseCase.self) { _ in
        ReportCommentUseCaseImpl(
            commentRepository: commentRepository,
            userRepository: userRepository
        )
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(BlockUserUseCase.self) { _ in
        BlockUserUseCaseImpl(userRepository: userRepository)
    }
    .inObjectScope(.transient)

    AppDIContainer.shared.container.register(UserRepository.self) { _ in
        userRepository
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
private func makeComment(id: String, authorUID: String) -> Domain.Comment {
    Domain.Comment(
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
