//
//  Story.swift
//  BanGiDa
//
//  Created by Codex on 1/??/25.
//

import SwiftUI

struct Story: Identifiable {
    let id = UUID()
    let imageName: String
    let time: String
    let nickname: String
    let text: String
    var isHearted: Bool
    let heartCount: Int
}

extension Story {
    static let mock: [Story] = [
        Story(
            imageName: "BasicDog",
            time: "5 years ago",
            nickname: "안경줄복학생",
            text: "hihihihihihihihih",
            isHearted: false,
            heartCount: 3
        ),
        Story(
            imageName: "BasicDog",
            time: "2 hours ago",
            nickname: "산책러버",
            text: "오늘은 산책 다녀왔어요!",
            isHearted: true,
            heartCount: 8
        ),
        Story(
            imageName: "BasicDog",
            time: "1 day ago",
            nickname: "고양이집사",
            text: "집사가 최고입니다.",
            isHearted: false,
            heartCount: 1
        ),
        Story(
            imageName: "BasicDog",
            time: "3 days ago",
            nickname: "동네영웅",
            text: "산책 중에 친구를 만났어요.",
            isHearted: false,
            heartCount: 5
        ),
        Story(
            imageName: "BasicDog",
            time: "1 week ago",
            nickname: "비오는날",
            text: "비가 와도 산책은 필수!",
            isHearted: true,
            heartCount: 12
        ),
        Story(
            imageName: "BasicDog",
            time: "2 weeks ago",
            nickname: "사진사",
            text: "오늘은 베스트샷 건졌습니다.",
            isHearted: false,
            heartCount: 2
        ),
        Story(
            imageName: "BasicDog",
            time: "3 weeks ago",
            nickname: "간식중독",
            text: "간식은 언제나 옳다.",
            isHearted: true,
            heartCount: 21
        ),
        Story(
            imageName: "BasicDog",
            time: "1 month ago",
            nickname: "훈련중",
            text: "앉아를 완벽하게 배웠어요!",
            isHearted: false,
            heartCount: 6
        ),
        Story(
            imageName: "BasicDog",
            time: "2 months ago",
            nickname: "장난꾸러기",
            text: "신발과의 전쟁은 계속된다.",
            isHearted: false,
            heartCount: 4
        ),
        Story(
            imageName: "BasicDog",
            time: "6 months ago",
            nickname: "아침산책",
            text: "아침 공기는 역시 최고네요.",
            isHearted: true,
            heartCount: 9
        )
    ]
}
