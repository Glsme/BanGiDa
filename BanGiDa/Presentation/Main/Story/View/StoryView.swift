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
    
    var body: some View {
        ScrollView {
            ForEach(stories.indices, id: \.self) { index in
                LazyVStack(spacing: Self.spacing) {
                    let story = stories[index]
                    StoryRow(
                        image: Image(story.imageName),
                        time: story.time,
                        nickname: story.nickname,
                        text: story.text,
                        isHearted: $stories[index].isHearted,
                        heartCount: story.heartCount
                    )
                        .padding(.vertical, 44)
                        .padding(.horizontal, 16)
                        .onAppear {
                            if index % 10 == 7 {
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
                    
                    Divider()
                }
            }
        }
    }
}

#Preview {
    StoryView()
}
