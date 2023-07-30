//
//  WriteView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2023/07/23.
//

import SwiftUI

struct WriteView: View {
    @State var memo: String = ""
    
    var body: some View {
        VStack {
            HStack {
                Image("BasicDog")
                    .resizable()
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.45)
            }
            .padding(10)
            
            Button {
                print("이미지 추가")
            } label: {
                Text("이미지 추가")
            }
            
            Divider()
                .foregroundColor(.black)
                .background(Color.black)
                .padding([.leading, .trailing], 16)
            
            Button {
                print("날짜 버튼 클릭")
            } label: {
                Text("2023.07.29 Sat")
            }

            Divider()
                .background(Color.black)
                .padding([.leading, .trailing], 16)
            
            TextEditor(text: $memo)
                .padding()
                .colorMultiply(.blue)
        } // VStack
    }
}

struct WriteView_Previews: PreviewProvider {
    static var previews: some View {
        WriteView()
    }
}
