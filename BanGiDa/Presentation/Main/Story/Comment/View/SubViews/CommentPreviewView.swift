//
//  CommentPreviewView.swift
//  BanGiDa
//

import SwiftUI
import DesignSystem

struct CommentPreviewView: View {
    let comments: [Comment]
    let commentCount: Int
    let storyWriterUID: String
    let onTap: () -> Void

    private var previewComments: [Comment] {
        Array(comments.prefix(CommentPolicy.previewCount))
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                if commentCount == 0 {
                    Text("첫 댓글을 남겨보세요")
                        .font(.custom("HelveticaNeue-Regular", size: 14))
                        .foregroundColor(.secondary)
                } else {
                    Divider()

                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(previewComments) { comment in
                            previewRow(comment)
                        }
                    }

                    if commentCount > CommentPolicy.previewCount {
                        Text("댓글 \(commentCount)개 모두 보기 ›")
                            .font(.custom("HelveticaNeue-Regular", size: 14))
                            .foregroundColor(Color.systemTintColor)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            commentCount == 0
                ? "첫 댓글을 남겨보세요"
                : "댓글 \(commentCount)개 보기"
        )
    }
}

private extension CommentPreviewView {
    @ViewBuilder
    func previewRow(_ comment: Comment) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 5) {
            Text(comment.authorNickname)
                .font(.custom("HelveticaNeue-Bold", size: 14))
                .foregroundColor(Color.systemTintColor)

            if comment.authorUID == storyWriterUID {
                Text("작성자")
                    .font(.custom("HelveticaNeue-Bold", size: 10))
                    .foregroundColor(Color.greenblue)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Color.greenblue.opacity(0.16))
                    .clipShape(Capsule())
                    .accessibilityHidden(true)
            }

            Text(" " + comment.text)
                .font(.custom("HelveticaNeue-Regular", size: 14))
                .foregroundColor(Color.systemTintColor)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            comment.authorUID == storyWriterUID
                ? "\(comment.authorNickname), 작성자, \(comment.text)"
                : "\(comment.authorNickname), \(comment.text)"
        )
    }
}
