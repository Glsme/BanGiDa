//
//  Story+Mock.swift
//  BanGiDa
//
//  Created by Codex on 1/??/25.
//

import Foundation

extension Story {
    static let mock: [Story] = [
        Story(
            id: "mock-1",
            writerUID: "mock-writer-1",
            imageURL: "BasicDog",
            time: "5 years ago",
            nickname: "안경줄복학생",
            text: "hihihihihihihihih",
            isHearted: false,
            heartCount: 3,
            commentCount: 2,
            previewComments: [
                Comment(
                    id: "mock-1-comment-1",
                    storyID: "mock-1",
                    authorUID: "mock-writer-1",
                    authorNickname: "안경줄복학생",
                    text: "날씨가 정말 좋네요!",
                    createdAt: Date(),
                    displayTime: "방금 전"
                ),
                Comment(
                    id: "mock-1-comment-2",
                    storyID: "mock-1",
                    authorUID: "mock-reader-1",
                    authorNickname: "고양이집사",
                    text: "저도 같이 산책하고 싶어요.",
                    createdAt: Date(),
                    displayTime: "1분 전"
                )
            ]
        ),
        Story(
            id: "mock-2",
            writerUID: "mock-writer-2",
            imageURL: "BasicDog",
            time: "2 hours ago",
            nickname: "산책러버",
            text: "오늘은 산책 다녀왔어요!",
            isHearted: true,
            heartCount: 8,
            commentCount: 0,
            previewComments: []
        ),
        Story(
            id: "mock-3",
            writerUID: "mock-writer-3",
            imageURL: "BasicDog",
            time: "1 day ago",
            nickname: "고양이집사",
            text: "집사가 최고입니다.",
            isHearted: false,
            heartCount: 1,
            commentCount: 4,
            previewComments: [
                Comment(
                    id: "mock-3-comment-1",
                    storyID: "mock-3",
                    authorUID: "mock-reader-3",
                    authorNickname: "반려견친구",
                    text: "정말 귀여워요!",
                    createdAt: Date(),
                    displayTime: "3분 전"
                ),
                Comment(
                    id: "mock-3-comment-2",
                    storyID: "mock-3",
                    authorUID: "mock-writer-3",
                    authorNickname: "고양이집사",
                    text: "칭찬해 주셔서 고마워요.",
                    createdAt: Date(),
                    displayTime: "5분 전"
                )
            ]
        ),
        Story(
            id: "mock-4",
            writerUID: "mock-writer-4",
            imageURL: "BasicDog",
            time: "3 days ago",
            nickname: "동네영웅",
            text: "산책 중에 친구를 만났어요.",
            isHearted: false,
            heartCount: 5,
            commentCount: 1,
            previewComments: [
                Comment(
                    id: "mock-4-comment-1",
                    storyID: "mock-4",
                    authorUID: "mock-reader-4",
                    authorNickname: "산책러버",
                    text: "친구를 만나다니 즐거웠겠어요.",
                    createdAt: Date(),
                    displayTime: "10분 전"
                )
            ]
        ),
        Story(
            id: "mock-5",
            writerUID: "mock-writer-5",
            imageURL: "BasicDog",
            time: "1 week ago",
            nickname: "비오는날",
            text: "비가 와도 산책은 필수!",
            isHearted: true,
            heartCount: 12,
            commentCount: 8,
            previewComments: []
        ),
        Story(
            id: "mock-6",
            writerUID: "mock-writer-6",
            imageURL: "BasicDog",
            time: "2 weeks ago",
            nickname: "사진사",
            text: "오늘은 베스트샷 건졌습니다.",
            isHearted: false,
            heartCount: 2,
            commentCount: 0,
            previewComments: []
        ),
        Story(
            id: "mock-7",
            writerUID: "mock-writer-7",
            imageURL: "BasicDog",
            time: "3 weeks ago",
            nickname: "간식중독",
            text: "간식은 언제나 옳다.",
            isHearted: true,
            heartCount: 21,
            commentCount: 5,
            previewComments: []
        ),
        Story(
            id: "mock-8",
            writerUID: "mock-writer-8",
            imageURL: "BasicDog",
            time: "1 month ago",
            nickname: "훈련중",
            text: "앉아를 완벽하게 배웠어요!",
            isHearted: false,
            heartCount: 6,
            commentCount: 3,
            previewComments: []
        ),
        Story(
            id: "mock-9",
            writerUID: "mock-writer-9",
            imageURL: "BasicDog",
            time: "2 months ago",
            nickname: "장난꾸러기",
            text: "신발과의 전쟁은 계속된다.",
            isHearted: false,
            heartCount: 4,
            commentCount: 0,
            previewComments: []
        ),
        Story(
            id: "mock-10",
            writerUID: "mock-writer-10",
            imageURL: "BasicDog",
            time: "6 months ago",
            nickname: "아침산책",
            text: "아침 공기는 역시 최고네요.",
            isHearted: true,
            heartCount: 9,
            commentCount: 6,
            previewComments: []
        )
    ]
}
