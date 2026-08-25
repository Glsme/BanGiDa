//
//  CommentRow.swift
//  BanGiDa
//

import SwiftUI
import DesignSystem
import Domain

struct CommentRow: View {
    let comment: Comment
    let isStoryAuthor: Bool
    let isMine: Bool
    let onDelete: () -> Void
    let onBlock: () -> Void

    @State private var isDeleteConfirmationPresented = false
    @State private var isReportSheetPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 8) {
                authorView

                Text(comment.displayTime)
                    .font(.custom("HelveticaNeue-Regular", size: 12))
                    .foregroundColor(.secondary)
            }

            Text(comment.text)
                .font(.custom("HelveticaNeue-Regular", size: 14))
                .foregroundColor(Color.systemTintColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 12)
        .contentShape(Rectangle())
        .contextMenu {
            // §6.4: 내 댓글은 삭제만, 남의 댓글은 신고·차단만 노출한다.
            if isMine {
                Button(role: .destructive) {
                    isDeleteConfirmationPresented = true
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            } else {
                Button {
                    isReportSheetPresented = true
                } label: {
                    Label("신고", systemImage: "exclamationmark.bubble")
                }

                Button(role: .destructive) {
                    onBlock()
                } label: {
                    Label("차단", systemImage: "hand.raised")
                }
            }
        }
        .confirmationDialog(
            "댓글을 삭제할까요?",
            isPresented: $isDeleteConfirmationPresented,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                onDelete()
            }
            Button("취소", role: .cancel) {}
        } message: {
            Text("삭제한 댓글은 되돌릴 수 없어요.")
        }
        .sheet(isPresented: $isReportSheetPresented) {
            ReportSheetView(
                target: .comment(storyID: comment.storyID, commentID: comment.id),
                targetAuthorUID: comment.authorUID,
                contentSnapshot: comment.text
            )
        }
    }
}

private extension CommentRow {
    @ViewBuilder
    var authorView: some View {
        HStack(spacing: 5) {
            Text(comment.authorNickname)
                .font(.custom("HelveticaNeue-Bold", size: 14))
                .foregroundColor(Color.systemTintColor)

            if isStoryAuthor {
                Text("작성자")
                    .font(.custom("HelveticaNeue-Bold", size: 10))
                    .foregroundColor(Color.greenblue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.greenblue.opacity(0.16))
                    .clipShape(Capsule())
                    .accessibilityHidden(true)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            isStoryAuthor
                ? "\(comment.authorNickname), 작성자"
                : comment.authorNickname
        )
    }
}
