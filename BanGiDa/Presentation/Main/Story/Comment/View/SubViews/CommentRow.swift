//
//  CommentRow.swift
//  BanGiDa
//

import SwiftUI

struct CommentRow: View {
    let comment: Comment
    let isStoryAuthor: Bool

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
