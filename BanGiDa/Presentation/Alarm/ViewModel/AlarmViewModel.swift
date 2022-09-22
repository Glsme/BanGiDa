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
    
    func saveData(content: String, dateText: String, titleText: String) {
        
        if let primaryKey = UserDiaryRepository.shared.primaryKey {
            editData(content: content, dateText: dateText, primaryKey: primaryKey, titleText: titleText)
        } else {
            let content = content
            let date = dateText.toDateAlarm() ?? Date()
            let animalName = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue)
            
            let task = Diary(type: RealmDiaryType(rawValue: 1), date: date, regDate: Date(), animalName: animalName ?? "신원 미상", content: content, photo: "", alarmTitle: titleText)
            UserDiaryRepository.shared.write(task)
            inputDataIntoArrayToDate(date: currentDate.value)
            
            sendNotification(title: titleText, body: content, date: date, index: alarmTaskList.count - 1)
        }
    }
    
    func editData(content: String, dateText: String, primaryKey: ObjectId, titleText: String) {
        var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil, alarmTitle: titleText)
        
        for item in UserDiaryRepository.shared.localRealm.objects(Diary.self) {
            if item.objectId == primaryKey {
                task = item
            }
        }
        
        let date = dateText.toDateAlarm() ?? Date()
        let regDate = Date()
        
        UserDiaryRepository.shared.update(task, date: date, regDate: regDate, content: content, image: "", alarmTitle: titleText)
        inputDataIntoArrayToDate(date: currentDate.value)
        sendNotification(title: titleText, body: content, date: date, index: alarmTaskList.count - 1)
        UserDiaryRepository.shared.primaryKey = nil
    }
}