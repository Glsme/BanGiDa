//
//  WriteViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit
import SnapKit
import RealmSwift

class WriteViewModel: CommonViewModel {
    
    var currentIndex: Observable<Int> = Observable(0)
    var diaryContent: Observable<String> = Observable("")
    var dateText: Observable<String> = Observable("")
    
    func setCurrentMemoType() -> SelectButtonModel {
        return selectButtonList[self.currentIndex.value]
    }
    
    func checkTextViewPlaceHolder(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func checkTextViewIsEmpty(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = setCurrentMemoType().placeholder
        }
    }
    
    func saveData(image: UIImage?, content: String, dateText: String) {
        
        if let primaryKey = UserDiaryRepository.shared.primaryKey {
            editData(image: image, content: content, dateText: dateText, primaryKey: primaryKey)
        } else {
            let image = image
            let content = content
            let date = dateText.toDate() ?? Date()
            
            print(date, "???")
            
            let task = Diary(type: RealmDiaryType(rawValue: currentIndex.value), date: date, regDate: Date(), animalName: "뱅돌이", content: content, photo: "", alarmTitle: nil)
            UserDiaryRepository.shared.write(task)
            
            if let image = image {
                saveImageToDocument(fileName: "\(task.objectId).jpg", image: image)
                imageEditing.value = true
            }
        }
    }
    
    func editData(image: UIImage?, content: String, dateText: String, primaryKey: ObjectId) {
        var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil, alarmTitle: nil)
        
        for item in UserDiaryRepository.shared.localRealm.objects(Diary.self) {
            if item.objectId == primaryKey {
                task = item
            }
        }
        
        let image = image
        let content = content
        let date = dateText.toDate() ?? Date()
        let regDate = Date()
        
        print(date, "???")
        
        UserDiaryRepository.shared.update(task, date: date, regDate: regDate, content: content, image: "", alarmTitle: nil)
        
        UserDiaryRepository.shared.primaryKey = nil
        
        if let image = image {
            saveImageToDocument(fileName: "\(task.objectId).jpg", image: image)
            imageEditing.value = true
        }
    }
    
    func saveImageToDocument(fileName: String, image: UIImage) {
        guard let documnetDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let fileURL = documnetDirectory.appendingPathComponent(fileName)
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        do {
            try data.write(to: fileURL)
        } catch let error {
            print("file save error", error)
        }
    }
}
