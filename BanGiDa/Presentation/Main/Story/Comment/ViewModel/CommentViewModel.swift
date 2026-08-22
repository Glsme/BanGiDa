//
//  CommentViewModel.swift
//  BanGiDa
//

import Foundation

@MainActor
final class CommentViewModel: ObservableObject {
    @Injected private var analyticsRepository: AnalyticsRepository
    @Injected private var fetchCommentsUseCase: FetchCommentsUseCase
    @Injected private var writeCommentUseCase: WriteCommentUseCase
    @Injected private var deleteCommentUseCase: DeleteCommentUseCase
    @Injected private var blockUserUseCase: BlockUserUseCase
    @Injected private var userRepository: UserRepository

    @Published var comments: [Comment] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isEnd = false
    @Published private(set) var isSending = false
    @Published var inputText = ""
    @Published var errorMessage: String?

    private let storyID: String
    private let storyWriterUID: String

    private var cursor: CommentCursor?
    private var hasLoadedOnce = false
    private var lastSuccessfulSendAt: Date?
    private var onCommentSent: (() -> Void)?
    private var onCommentDeleted: (() -> Void)?

    init(
        storyID: String,
        storyWriterUID: String
    ) {
        self.storyID = storyID
        self.storyWriterUID = storyWriterUID
    }

    func loadInitialIfNeeded() {
        guard !hasLoadedOnce else { return }
        hasLoadedOnce = true

        Task { await fetchComments(reset: true) }
    }

    func loadMoreIfNeeded(currentCommentID: Comment.ID) {
        guard currentCommentID == comments.last?.id else { return }
        guard !isEnd else { return }

        Task { await fetchComments(reset: false) }
    }

    func send() {
        guard !isSending else { return }

        if let lastSuccessfulSendAt,
           Date().timeIntervalSince(lastSuccessfulSendAt) < CommentPolicy.writeCooldown {
            handle(error: CommentError.rateLimited)
            return
        }

        let text = inputText

        Task {
            do {
                isSending = true
                defer { isSending = false }

                let comment = try await writeCommentUseCase.execute(storyID: storyID, text: text)
                comments.insert(comment, at: 0)
                inputText = ""
                errorMessage = nil
                lastSuccessfulSendAt = Date()
                onCommentSent?()
            } catch {
                handle(error: error)
            }
        }
    }

    func isStoryAuthor(_ comment: Comment) -> Bool {
        comment.authorUID == storyWriterUID
    }

    func isMine(_ comment: Comment) -> Bool {
        comment.authorUID == userRepository.loadUID()
    }

    func observeSuccessfulSend(_ action: @escaping () -> Void) {
        onCommentSent = action
    }

    func observeSuccessfulDelete(_ action: @escaping () -> Void) {
        onCommentDeleted = action
    }

    func delete(comment: Comment) {
        Task {
            do {
                try await deleteCommentUseCase.execute(comment: comment)
                comments.removeAll { $0.id == comment.id }
                errorMessage = nil
                onCommentDeleted?()
                analyticsRepository.logEvent("Delete_Comment", parameters: nil)
            } catch {
                handle(error: error)
            }
        }
    }

    func block(comment: Comment) {
        Task {
            do {
                try await blockUserUseCase.execute(targetUID: comment.authorUID)
                // §8.2: 차단은 화면에서 즉시 숨기는 클라이언트 필터다. 서버의 commentCount는
                // 그대로 두고(다음 새로고침에서 FetchCommentsUseCase가 다시 걸러낸다) 목록에서만 제거한다.
                comments.removeAll { $0.authorUID == comment.authorUID }
                analyticsRepository.logEvent("Block_User", parameters: nil)
            } catch {
                handle(error: error)
            }
        }
    }

    // MARK: - Private

    private func fetchComments(reset: Bool) async {
        guard !isLoading else { return }
        isLoading = true

        defer { isLoading = false }

        do {
            let page = try await fetchCommentsUseCase.execute(
                storyID: storyID,
                after: reset ? nil : cursor
            )

            if reset {
                comments = page.comments
            } else {
                comments.append(contentsOf: page.comments)
            }

            cursor = page.nextCursor
            // 커서를 만들지 못하면 다음 요청이 첫 페이지를 다시 불러와 중복이 쌓이므로 종료로 처리한다.
            isEnd = page.isEnd || page.nextCursor == nil
        } catch {
            handle(error: error)
        }
    }

    private func handle(error: Error) {
        analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])

        switch error {
        case CommentError.emptyText:
            errorMessage = "댓글 내용을 입력해 주세요."
        case CommentError.textTooLong:
            errorMessage = "댓글은 300자까지 입력할 수 있어요."
        case CommentError.containsProhibitedWord:
            errorMessage = "사용할 수 없는 표현이 포함되어 있어요"
        case CommentError.rateLimited:
            errorMessage = "잠시 후 다시 전송해 주세요."
        case CommentError.notAuthor:
            errorMessage = "본인이 작성한 댓글만 삭제할 수 있어요."
        default:
            errorMessage = "댓글을 처리하지 못했어요. 다시 시도해 주세요."
        }
    }
}
