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
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: Self.spacing) {
                    ForEach(Array(viewModel.stories.enumerated()), id: \.element.id) { index, story in
                        StoryRow(
                            imageURL: story.imageURL,
                            time: story.time,
                            nickname: story.nickname,
                            text: story.text,
                            isHearted: $viewModel.stories[index].isHearted,
                            heartCount: story.heartCount
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
    func presentWriteStoryView() {
        isWriteStoryPresented = true
    }
}

#Preview {
    StoryView()
}
