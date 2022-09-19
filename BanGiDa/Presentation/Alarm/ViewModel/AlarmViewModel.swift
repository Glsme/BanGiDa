//
//  AlarmViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/19.
//

import UIKit
import RealmSwift

class AlarmViewModel: CommonViewModel {
    var dateText: Observable<String> = Observable("")
    var diaryContent: Observable<String> = Observable("")
    
    func checkTextViewPlaceHolder(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func checkTextViewIsEmpty(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.textColor = .lightGray
            textView.text = selectButtonList[1].placeholder
        }
    }
    
    func saveData(content: String, dateText: String) {
        
        if let primaryKey = UserDiaryRepository.shared.primaryKey {
            editData(content: content, dateText: dateText, primaryKey: primaryKey)
        } else {
            let content = content
            let date = dateText.toDateAlarm() ?? Date()
            
            let task = Diary(type: RealmDiaryType(rawValue: 1), date: date, regDate: Date(), animalName: "뱅돌이", content: content, photo: "")
            UserDiaryRepository.shared.write(task)
        }
    }
    
    func editData(content: String, dateText: String, primaryKey: ObjectId) {
        var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil)
        
        for item in UserDiaryRepository.shared.localRealm.objects(Diary.self) {
            if item.objectId == primaryKey {
                task = item
            }
        }
        
        let content = content
        let date = dateText.toDate() ?? Date()
        let regDate = Date()
        
        UserDiaryRepository.shared.update(task, date: date, regDate: regDate, content: content, image: "")
        
        UserDiaryRepository.shared.primaryKey = nil
    }
}
