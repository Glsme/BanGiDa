//
//  WalkThroughView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import Foundation

import Firebase
import FirebaseStorage

final class NoticeViewModel: ObservableObject {
    private let urlString = "gs://bangida-c9736.appspot.com/"
    
    @Published var image: Data? = nil
    
    func downloadImage() {
        let storage = Storage.storage().reference(forURL: "\(urlString)image_0.jpg")
        let megaByte = Int64(1 * 1024 * 1024)
        
        storage.getData(maxSize: megaByte) { [weak self] data, error in
            guard let self else { return }
            guard let imageData = data else {
                print("이미지 다운로드 실패: 이미지 없음")
                
                return
            }
            
            image = imageData
        }
    }
}
