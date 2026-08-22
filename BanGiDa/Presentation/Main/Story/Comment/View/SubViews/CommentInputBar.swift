//
//  CommentInputBar.swift
//  BanGiDa
//

import SwiftUI

struct CommentInputBar: View {
    @Binding var text: String

    let isSending: Bool
    let onSend: () -> Void

    private var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var remainingCharacterCount: Int {
        CommentPolicy.maxLength - text.count
    }

    private var shouldShowCharacterCount: Bool {
        text.count >= CommentPolicy.maxLength - 30
    }

    var body: some View {
        HStack(alignment: .bottom, spacing: 10) {
            VStack(alignment: .trailing, spacing: 4) {
                TextField("댓글을 입력해 주세요", text: $text, axis: .vertical)
                    .lineLimit(1...4)
                    .font(.custom("HelveticaNeue-Regular", size: 14))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    // 한 줄만 입력해도 눌리는 영역이 확보되도록 최소 높이를 준다(HIG 44pt).
                    .frame(minHeight: 44)
                    .background(Color.memoBackgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .onChange(of: text) { newValue in
                        if newValue.count > CommentPolicy.maxLength {
                            text = String(newValue.prefix(CommentPolicy.maxLength))
                        }
                    }

                if shouldShowCharacterCount {
                    Text("\(remainingCharacterCount)")
                        .font(.custom("HelveticaNeue-Regular", size: 11))
                        .foregroundColor(remainingCharacterCount == 0 ? .red : .secondary)
                }
            }

            Button(action: onSend) {
                if isSending {
                    ProgressView()
                        .frame(width: 30, height: 30)
                } else {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 30))
                        .foregroundColor(Color.greenblue)
                }
            }
            .disabled(trimmedText.isEmpty || isSending)
            .opacity(trimmedText.isEmpty || isSending ? 0.45 : 1)
            .accessibilityLabel("댓글 전송")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.backgroundColor)
    }
}
