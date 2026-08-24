//
//  StoryRow.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/23/25.
//

import Foundation
import SwiftUI
import DesignSystem

struct StoryRow: View {
    let storyID: String
    let imageURL: String
    let time: String
    let nickname: String
    let text: String
    let storyWriterUID: String
    let heartCount: Int
    let commentCount: Int
    let previewComments: [Comment]
    let showsHotBadge: Bool
    let onHeartTap: () -> Void
    let onCommentChanged: (Int, [Comment]) -> Void
    
    @Binding var isHearted: Bool
    @State private var isReportSheetPresented = false
    @State private var isCommentSheetPresented = false
    
    init(
        storyID: String,
        imageURL: String,
        time: String,
        nickname: String,
        text: String,
        storyWriterUID: String,
        showsHotBadge: Bool,
        isHearted: Binding<Bool>,
        heartCount: Int,
        commentCount: Int,
        previewComments: [Comment],
        onHeartTap: @escaping () -> Void = {},
        onCommentChanged: @escaping (Int, [Comment]) -> Void = { _, _ in }
    ) {
        self.storyID = storyID
        self.imageURL = imageURL
        self.time = time
        self.nickname = nickname
        self.text = text
        self.storyWriterUID = storyWriterUID
        self.showsHotBadge = showsHotBadge
        self._isHearted = isHearted
        self.heartCount = heartCount
        self.commentCount = commentCount
        self.previewComments = previewComments
        self.onHeartTap = onHeartTap
        self.onCommentChanged = onCommentChanged
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .top) {
                storyImageView
                
                HStack(alignment: .top) {
                    if showsHotBadge {
                        VStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.red)
                            
                            Text("HOT")
                                .font(.custom("HelveticaNeue-Bold", size: 8))
                                .foregroundStyle(Color.red)
                        }
                        .padding(12)
                    }
                    
                    Spacer()
                    
                    Button {
                        isReportSheetPresented = true
                    } label: {
                        Image(systemName: "light.beacon.max.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                            .foregroundStyle(.gray)
                            .fontWeight(.bold)
                    }
                    .padding(12)
                }
            }
            
            HStack {
                heartView(count: heartCount)
                commentView(count: commentCount)
                Spacer()
                timeView(time)
            }
            .padding(.trailing, 4)
            .padding(.bottom, 4)
            
            writingView(nickname: nickname, text: text)
                .padding(.leading, 2)

            CommentPreviewView(
                comments: previewComments,
                commentCount: commentCount,
                storyWriterUID: storyWriterUID,
                onTap: { isCommentSheetPresented = true }
            )
        }
        .sheet(isPresented: $isReportSheetPresented) {
            ReportSheetView(
                target: .story(storyID: storyID),
                targetAuthorUID: storyWriterUID,
                contentSnapshot: text
            )
        }
        .sheet(isPresented: $isCommentSheetPresented) {
            CommentSheetView(
                storyID: storyID,
                storyWriterUID: storyWriterUID,
                initialCommentCount: commentCount,
                onCommentChanged: onCommentChanged
            )
        }
    }
}

private extension StoryRow {
    @ViewBuilder
    var storyImageView: some View {
        if let url = URL(string: imageURL), url.scheme != nil {
            CachedAsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                default:
                    Image("BasicDog")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        } else {
            Image(imageURL)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    @ViewBuilder
    func heartView(count: Int) -> some View {
        HStack(spacing: 4) {
            Button {
                onHeartTap()
            } label: {
                Image(systemName: isHearted ? "heart.fill" : "heart")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(isHearted ? .red : .systemTintColor)
                    .frame(width: 20, height: 20)
            }
            
            Text("\(count)")
                .font(.custom("HelveticaNeue-Regular", size: 14))
        }
        .frame(maxHeight: 20)
    }

    @ViewBuilder
    func commentView(count: Int) -> some View {
        Button {
            isCommentSheetPresented = true
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "bubble.left")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)

                Text("\(count)")
                    .font(.custom("HelveticaNeue-Regular", size: 14))
            }
            .foregroundColor(Color.systemTintColor)
        }
        .frame(maxHeight: 20)
        .accessibilityLabel("댓글 \(count)개")
    }
    
    @ViewBuilder
    func timeView(_ time: String) -> some View {
        Text(time)
            .font(.custom("HelveticaNeue-Regular", size: 14))
    }
    
    @ViewBuilder
    func writingView(nickname: String, text: String) -> some View {
        (
            Text(nickname)
                .font(.custom("HelveticaNeue-Bold", size: 14))
            + Text(" " + text)
                .font(.custom("HelveticaNeue-Regular", size: 14))
        )
        .frame(maxWidth: .infinity, alignment: .leading)
//        .lineLimit(2)
        .truncationMode(.tail)
    }
}

#Preview {
    StoryRow(
        storyID: "preview-story",
        imageURL: "BasicDog",
        time: "5 hours ago",
        nickname: "안경줄복학생",
        text: "저희집 고양이 귀엽죠? 너도 한번 보시길 바라요! 12345678901234567890123456789012345678901234567890123456789",
        storyWriterUID: "preview-writer",
        showsHotBadge: true,
        isHearted: .constant(false),
        heartCount: 2,
        commentCount: 3,
        previewComments: [
            Comment(
                id: "preview-comment-1",
                storyID: "preview-story",
                authorUID: "preview-writer",
                authorNickname: "안경줄복학생",
                text: "날씨가 정말 좋네요!",
                createdAt: Date(),
                displayTime: "방금 전"
            ),
            Comment(
                id: "preview-comment-2",
                storyID: "preview-story",
                authorUID: "preview-reader",
                authorNickname: "고양이집사",
                text: "정말 귀여워요.",
                createdAt: Date(),
                displayTime: "1분 전"
            )
        ],
        onHeartTap: {}
    )
}
