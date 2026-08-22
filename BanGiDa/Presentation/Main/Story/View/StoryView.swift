//
//  StoryView.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/8/25.
//

import SwiftUI

struct StoryView: View {
    private static let spacing: CGFloat = 2
    
    @StateObject private var viewModel = StoryViewModel()
    @State private var isWriteStoryPresented = false
    @State private var shouldRefreshAfterWrite = false
    @AppStorage(UserDefaultsKey.storyAgreementVersion.rawValue) private var storyAgreementVersion = 0
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: Self.spacing) {
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
                            onHeartTap: {
                                viewModel.toggleStoryLike(index: index)
                            },
                            onCommentChanged: { count, comments in
                                viewModel.updateCommentCount(storyID: story.id, count: count)
                                viewModel.updateCommentPreview(storyID: story.id, comments: comments)
                            }
                        )
                        .padding(.top, index == 0 ? 0 : 44)
                        .padding(.bottom, 44)
                        .padding(.horizontal, 16)
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentStoryID: story.id)
                            viewModel.prefetchImages(from: index)
                        }
                        
                        Divider()
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

            if shouldPresentStoryGuide {
                StoryGuideOverlay(onAgree: {
                    storyAgreementVersion = StoryGuidePolicy.currentVersion
                })
            }
        }
        .background(Color.backgroundColor)
        .task {
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
    // 댓글은 새로운 종류의 UGC다. 사진 정책에만 동의한 사용자에게 댓글 제재 조항을
    // 고지 없이 적용하면 근거가 약하고, 심사 대응 시 댓글 정책 고지 시점을 설명할 수 없다.
    var shouldPresentStoryGuide: Bool {
        effectiveStoryAgreementVersion < StoryGuidePolicy.currentVersion
    }

    var effectiveStoryAgreementVersion: Int {
        let versionKey = UserDefaultsKey.storyAgreementVersion.rawValue

        if UserDefaults.standard.object(forKey: versionKey) == nil,
           UserDefaults.standard.bool(forKey: UserDefaultsKey.storyAgreement.rawValue) {
            return 1
        }

        return storyAgreementVersion
    }

    func presentWriteStoryView() {
        isWriteStoryPresented = true
    }
}

#Preview {
    StoryView()
}
