//
//  UIViewController+Extension.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit

extension UIViewController {
    enum Transition {
        case push
        case presentNavigation
        case presentFullScreenNavigation
        case present
    }
    
    func transViewController<T: UIViewController>(ViewController vc: T, type: Transition) {
        switch type {
        case .push:
            self.navigationController?.pushViewController(vc, animated: true)
        case .present:
            present(vc, animated: true)
        case .presentNavigation:
            let navi = UINavigationController(rootViewController: vc)
            self.present(navi, animated: true)
        case .presentFullScreenNavigation:
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            self.present(navi, animated: true)
        }
    }
}

extension UIViewController {
    
    func documentDirectoryPath() -> URL? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        return documentDirectory
    }
    
    func loadImageFromDocument(fileName: String) -> UIImage? {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path) {
            return UIImage(contentsOfFile: fileURL.path)
        } else {
            return UIImage(systemName: "star.fill")
        }
    }
    
    func removeImageFromDocument(fileName: String) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent(fileName) // 세부 경로. 이미지를 저장할 위치
        
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print(error)
        }
    }
    
    func saveImageFromDocument(fileName: String, image: UIImage) {
        guard let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documentDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        do {
            try data.write(to: fileURL)
        } catch {
            print("file save Error", error)
        }
    }
    
    func fetchDocumentZipFile() {
        do {
            guard let path = documentDirectoryPath() else { return }
            let docs = try FileManager.default.contentsOfDirectory(at: path, includingPropertiesForKeys: nil)
            print("docs: \(docs)")
            
            let zip = docs.filter { $0.pathExtension == "zip" }
            print("zip: \(zip)")
            
            let result = zip.map { $0.lastPathComponent }
            print(result)
            
            //이후 테이블뷰로 연결 -> 클로저로 전달 예정
            
        } catch {
            print("Error")
        }
    }
}
