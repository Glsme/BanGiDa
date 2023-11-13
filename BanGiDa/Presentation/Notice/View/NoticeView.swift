//
//  WalkThroughView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import SwiftUI

struct NoticeView: View {
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            ScrollView {
                Image("ColorDog")
                    .resizable()
                    .scaledToFill()
                    .padding(8)
                
                Text("안녕하세요")
            }
            .navigationBarItems(trailing: closeButton())
        }
    }
}

private extension NoticeView {
    @ViewBuilder func closeButton() -> some View {
        Button {
            presentationMode.wrappedValue.dismiss()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 16, height: 16, alignment: .trailing)
                .foregroundColor(.systemTintColor)
                .padding(.trailing, 16)
        }
    }
}
