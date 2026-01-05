//
//  StoryGuideOverlay.swift
//  BanGiDa
//
//  Created by Codex on 3/8/25.
//

import SwiftUI

struct StoryGuideOverlay: View {
    let onAgree: () -> Void

    var body: some View {
        ZStack {
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                Text("스토리 이용 안내 🐶🐱")
                    .font(.custom("HelveticaNeue-Bold", size: 22))
                    .foregroundColor(Color.systemTintColor)

                VStack(alignment: .leading, spacing: 12) {
                    text("이 공간은 반려동물을 사랑하는 사람들을 위한 공간이에요.", fontSize: 14)
                    text("모두가 즐겁게 이용할 수 있도록 다음 사항을 꼭 지켜주세요.", fontSize: 14)

                    VStack(alignment: .leading, spacing: 8) {
                        text("• 반려동물과 관련된 사진만 업로드해 주세요.")
                        text("• 폭력적이거나 혐오감을 줄 수 있는 콘텐츠는 허용되지 않습니다.")
                        text("• 신고된 게시물은 운영자가 검토 후 삭제될 수 있습니다.")
                    }
                    .padding(.vertical, 12)

                    text("서로를 배려하는 따뜻한 공간을 함께 만들어 주세요.", fontSize: 14)
                }

                Button(action: onAgree) {
                    Text("동의하고 시작하기")
                        .font(.custom("HelveticaNeue-Bold", size: 16))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.greenblue)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
            }
            .padding(24)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
        }
    }
}

private extension StoryGuideOverlay {
    @ViewBuilder
    func text(_ text: String, fontSize: CGFloat = 12) -> some View {
        Text(text)
            .font(.custom("HelveticaNeue-Medium", size: fontSize))
            .foregroundColor(Color.systemTintColor)
    }
}

#Preview {
    StoryGuideOverlay(onAgree: {})
}
