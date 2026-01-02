//
//  StoryRow.swift
//  BanGiDa
//
//  Created by 홍석준 on 12/23/25.
//

import SwiftUI

struct StoryRow: View {
    let image: Image
    let time: String
    let nickname: String
    let text: String
    let heartCount: Int
    
    @Binding var isHearted: Bool
    
    init(
        image: Image,
        time: String,
        nickname: String,
        text: String,
        isHearted: Binding<Bool>,
        heartCount: Int
    ) {
        self.image = image
        self.time = time
        self.nickname = nickname
        self.text = text
        self._isHearted = isHearted
        self.heartCount = heartCount
    }
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack(alignment: .topTrailing) {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Button {
                    print("신고 버튼 탭")
                } label: {
                    Image(systemName: "light.beacon.max")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(Color.black)
                        .fontWeight(.bold)
                }
                .padding(12)
            }
            
            HStack {
                heartView(count: heartCount)
                Spacer()
                timeView(time)
            }
            .padding(.trailing, 4)
            .padding(.bottom, 4)
            
            writingView(nickname: nickname, text: text)
                .padding(.leading, 2)
        }
    }
}

private extension StoryRow {
    @ViewBuilder
    func heartView(count: Int) -> some View {
        HStack(spacing: 4) {
            Button {
                isHearted.toggle()
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
        .lineLimit(2)
        .truncationMode(.tail)
    }
}

#Preview {
    StoryRow(
        image: Image("BasicDog"),
        time: "5 hours ago",
        nickname: "안경줄복학생",
        text: "저희집 고양이 귀엽죠? 너도 한번 보시길 바라요! 12345678901234567890123456789012345678901234567890123456789",
        isHearted: .constant(false),
        heartCount: 2
    )
}
