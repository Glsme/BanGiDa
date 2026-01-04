//
//  ReportSheetView.swift
//  BanGiDa
//
//  Created by Codex on 1/??/26.
//

import SwiftUI

struct ReportSheetView: View {
    @StateObject private var viewModel = ReportViewModel()
    
    @Environment(\.dismiss) private var dismiss
    @State private var reason = ""
    
    private let imageURL: String
    
    public init(imageURL: String) {
        self.imageURL = imageURL
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("신고하기")
                    .font(.custom("HelveticaNeue-Bold", size: 18))
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray)
                }
            }

            Text("신고 사유는 선택사항이에요.")
                .font(.custom("HelveticaNeue-Regular", size: 13))
                .foregroundColor(.secondary)

            ZStack(alignment: .topLeading) {
                if reason.isEmpty {
                    Text("신고 사유를 입력해 주세요 (선택)")
                        .font(.custom("HelveticaNeue-Regular", size: 13))
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }

                TextEditor(text: $reason)
                    .scrollContentBackground(.hidden)
                    .font(.custom("HelveticaNeue-Regular", size: 13))
                    .frame(minHeight: 120)
                    .padding(2)
                    .background(Color.memoBackgroundColor)
            }

            Button {
                viewModel.report(text: reason, imageURL: imageURL)
                dismiss()
            } label: {
                Text("신고 접수")
                    .font(.custom("HelveticaNeue-Bold", size: 16))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.red)
                    .clipShape(Capsule())
            }

            Button {
                dismiss()
            } label: {
                Text("취소")
                    .font(.custom("HelveticaNeue-Regular", size: 14))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(20)
        .presentationDetents([.medium])
    }
}

#Preview {
    ReportSheetView(imageURL: "")
}
