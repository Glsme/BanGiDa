//
//  StoryView.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/8/25.
//

import SwiftUI

struct StoryView: View {
    private static let spacing: CGFloat = 2
    
    @State private var currentPage = 0
    @State private var stories: [Story] = Story.mock
    @State private var isWriteStoryPresented = false
    @State private var lastLoadedStoryID: Story.ID?
    @State private var hasMoreStories = true
    private let maxPage = 3
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                LazyVStack(spacing: Self.spacing) {
                    ForEach(Array(stories.enumerated()), id: \.element.id) { index, story in
                        StoryRow(
                            image: Image(story.imageName),
                            time: story.time,
                            nickname: story.nickname,
                            text: story.text,
                            isHearted: $stories[index].isHearted,
                            heartCount: story.heartCount
                        )
                        .padding(.top, index == 0 ? 0 : 44)
                        .padding(.bottom, 44)
                        .padding(.horizontal, 16)
                        .onAppear {
                            loadMoreIfNeeded(currentStoryID: story.id)
                        }
                        
                        Divider()
                    }

                    if !hasMoreStories {
                        Text("더 이상 불러올 스토리가 없어요.")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                            .padding(.vertical, 24)
                    }
                }
            }
            
            Button(action: presentWriteStoryView) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 56, height: 56)
                    .background(Color.unaBlue)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 4)
            }
            .padding(.trailing, 20)
            .padding(.bottom, 24)
        }
        .background(Color.backgroundColor)
        .fullScreenCover(isPresented: $isWriteStoryPresented) {
            WriteStoryView()
        }
    }
}

private extension StoryView {
    func presentWriteStoryView() {
        isWriteStoryPresented = true
    }

    func loadMoreIfNeeded(currentStoryID: Story.ID) {
        guard currentStoryID == stories.last?.id else { return }
        guard lastLoadedStoryID != currentStoryID else { return }
        guard hasMoreStories else { return }
        lastLoadedStoryID = currentStoryID
        if currentPage >= maxPage {
            hasMoreStories = false
            return
        }
        currentPage += 1
        stories.append(
            Story(
                imageName: "BasicDog",
                time: "just now",
                nickname: "새로운친구",
                text: "새로운 스토리가 추가됐어요.",
                isHearted: false,
                heartCount: 0
            )
        )
    }
}

#Preview {
    StoryView()
}
