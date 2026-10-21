//
//  StoryView.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/8/25.
//

import SwiftUI

struct StoryView: View {
    private static let spacing: CGFloat = 2
    
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @StateObject private var viewModel = StoryViewModel()
    @State private var isWriteStoryPresented = false
    @State private var shouldRefreshAfterWrite = false
    @AppStorage(UserDefaultsKey.storyAgreementVersion.rawValue) private var storyAgreementVersion = 0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            feedView
            
            Button(action: presentWriteStoryView) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.greenblue)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)

            if storyAgreementVersion < StoryGuidePolicy.currentVersion {
                StoryGuideOverlay(onAgree: {
                    storyAgreementVersion = StoryGuidePolicy.currentVersion
                })
            }
        }
        .background(Color.backgroundColor)
        .task {
            // 댓글은 새로운 종류의 UGC다. 사진 정책에만 동의한 사용자에게 댓글 제재
            // 조항을 고지 없이 적용할 수 없어, 레거시 동의를 버전 1로 올려 재동의를 받는다.
            StoryGuidePolicy.migrateLegacyAgreementIfNeeded()
            viewModel.loadInitialIfNeeded()
        }
        .fullScreenCover(isPresented: $isWriteStoryPresented, onDismiss: {
            guard shouldRefreshAfterWrite else { return }
            shouldRefreshAfterWrite = false
            Task { await viewModel.refresh() }
        }) {
            WriteStoryView(onFinish: {
                shouldRefreshAfterWrite = true
            })
        }
    }
}

private extension StoryView {
    var feedView: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    LazyVGrid(columns: gridColumns, alignment: .center, spacing: Self.spacing) {
                        ForEach(Array(viewModel.stories.enumerated()), id: \.element.id) { index, story in
                            StoryRow(
                                storyID: story.id,
                                imageURL: story.imageURL,
                                time: story.time,
                                nickname: story.nickname,
                                text: story.text,
                                storyWriterUID: story.writerUID,
                                showsHotBadge: index < 3 && story.heartCount > 0,
                                isHearted: $viewModel.stories[index].isHearted,
                                heartCount: story.heartCount,
                                commentCount: story.commentCount,
                                previewComments: story.previewComments,
                                maxImageHeight: isRegularWidth ? geometry.size.height * 0.6 : .infinity,
                                onHeartTap: {
                                    viewModel.toggleStoryLike(index: index)
                                },
                                onCommentChanged: { count, comments in
                                    viewModel.updateCommentCount(storyID: story.id, count: count)
                                    viewModel.updateCommentPreview(storyID: story.id, comments: comments)
                                }
                            )
                            .padding(.top, index < gridColumns.count ? 0 : 44)
                            .padding(.bottom, 44)
                            .padding(.horizontal, 16)
                            .overlay(alignment: .bottom) {
                                // 2열에서는 좌우 글 높이가 달라 구분선이 어긋나므로 1열에서만 긋는다.
                                if gridColumns.count == 1 {
                                    Divider()
                                }
                            }
                            .onAppear {
                                viewModel.loadMoreIfNeeded(currentStoryID: story.id)
                                viewModel.prefetchImages(from: index)
                            }
                        }
                    }

                    if viewModel.isEnd {
                        Text("더 이상 불러올 스토리가 없어요.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 24)
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
        }
    }

    var isRegularWidth: Bool {
        horizontalSizeClass == .regular
    }

    // iPhone·iPhone Duo 바깥 화면(compact)은 1열, Duo 안쪽 화면(regular)은 2열로 보여준다.
    // 짝수 열이면 Duo를 책처럼 반쯤 접었을 때 접힘선을 기준으로 깔끔하게 나뉜다(HIG — Designing for iPhone Duo).
    var gridColumns: [GridItem] {
        let count = isRegularWidth ? 2 : 1
        return Array(repeating: GridItem(.flexible(), spacing: 0, alignment: .top), count: count)
    }

    func presentWriteStoryView() {
        isWriteStoryPresented = true
    }
}

#Preview {
    StoryView()
}
