//
//  CommentSheetView.swift
//  BanGiDa
//

import SwiftUI

struct CommentSheetView: View {
    @StateObject private var viewModel: CommentViewModel
    @State private var commentCount: Int

    @Environment(\.dismiss) private var dismiss

    private let onCommentCountChanged: (Int) -> Void

    init(
        storyID: String,
        storyWriterUID: String,
        onCommentCountChanged: @escaping (Int) -> Void
    ) {
        self.init(
            storyID: storyID,
            storyWriterUID: storyWriterUID,
            initialCommentCount: 0,
            onCommentCountChanged: onCommentCountChanged
        )
    }

    init(
        storyID: String,
        storyWriterUID: String,
        initialCommentCount: Int = 0,
        onCommentCountChanged: @escaping (Int) -> Void
    ) {
        _viewModel = StateObject(
            wrappedValue: CommentViewModel(
                storyID: storyID,
                storyWriterUID: storyWriterUID
            )
        )
        _commentCount = State(initialValue: initialCommentCount)
        self.onCommentCountChanged = onCommentCountChanged
    }

    var body: some View {
        VStack(spacing: 0) {
            headerView
            Divider()
            contentView
            Divider()
            CommentInputBar(
                text: $viewModel.inputText,
                isSending: viewModel.isSending,
                onSend: viewModel.send
            )
        }
        .background(Color.backgroundColor)
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .onAppear {
            viewModel.observeSuccessfulSend {
                commentCount += 1
                onCommentCountChanged(commentCount)
            }
            viewModel.loadInitialIfNeeded()
        }
        .alert(
            "댓글을 처리하지 못했어요",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.errorMessage = nil
                    }
                }
            )
        ) {
            Button("확인", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

private extension CommentSheetView {
    var headerView: some View {
        HStack {
            Text("댓글 \(commentCount)")
                .font(.custom("HelveticaNeue-Bold", size: 18))

            Spacer()

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray)
            }
            .accessibilityLabel("댓글 시트 닫기")
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    @ViewBuilder
    var contentView: some View {
        if viewModel.isLoading && viewModel.comments.isEmpty {
            VStack {
                Spacer()
                ProgressView()
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.comments.isEmpty {
            VStack {
                Spacer()
                Text("아직 댓글이 없어요. 첫 댓글을 남겨보세요")
                    .font(.custom("HelveticaNeue-Regular", size: 14))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.comments) { comment in
                        CommentRow(
                            comment: comment,
                            isStoryAuthor: viewModel.isStoryAuthor(comment)
                        )
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentCommentID: comment.id)
                        }

                        Divider()
                    }

                    if viewModel.isLoading {
                        ProgressView()
                            .padding(.vertical, 16)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}
