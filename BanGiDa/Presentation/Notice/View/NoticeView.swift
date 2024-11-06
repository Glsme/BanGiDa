//
//  WalkThroughView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import SwiftUI

struct NoticeView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @StateObject private var viewModel = NoticeViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if let data = viewModel.image,
                   let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .padding(8)
                } else {
                    Image("ColorDog")
                        .resizable()
                        .scaledToFill()
                        .padding(8)
                }
                
                Text("안녕하세요")
            }
            .navigationBarItems(trailing: closeButton())
        }
        .onAppear {
            viewModel.downloadImage()
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
