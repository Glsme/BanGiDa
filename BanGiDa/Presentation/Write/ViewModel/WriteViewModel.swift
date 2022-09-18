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
    
    func saveData(image: String?, content: String, dateText: String) {
        
        if let primaryKey = UserDiaryRepository.shared.primaryKey {
            editData(image: image, content: content, dateText: dateText, primaryKey: primaryKey)
        } else {
            let image = image
            let content = content
            let date = dateText.toDate() ?? Date()
            
            let task = Diary(type: RealmDiaryType(rawValue: currentIndex.value), date: date, regDate: Date(), animalName: "뱅돌이", content: content, photo: image)
            UserDiaryRepository.shared.write(task)
        }
    }
    
    func editData(image: String?, content: String, dateText: String, primaryKey: ObjectId) {
        var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil)
        
        for item in UserDiaryRepository.shared.localRealm.objects(Diary.self) {
            if item.objectId == primaryKey {
                task = item
            }
        }
        
        let image = image
        let content = content
        let date = dateText.toDate() ?? Date()
        let regDate = Date()
        
        UserDiaryRepository.shared.update(task, date: date, regDate: regDate, content: content, image: image)
        
        UserDiaryRepository.shared.primaryKey = nil
    }
}
