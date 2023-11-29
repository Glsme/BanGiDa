//
//  AlarmViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/19.
//

import Combine
import Foundation

import FirebaseAnalytics
import FirebaseCrashlytics
import RealmSwift

final class AlarmViewModel: CommonViewModel {
    let dateText = CurrentValueSubject<String, Never>("")
    let diaryContent = CurrentValueSubject<String, Never>("")
    
    func saveData(content: String, dateText: String, titleText: String) {
        Analytics.logEvent("SaveAlarm", parameters: [
          "name": "BangiDaLog",
          "full_text": "Save Alarm",
        ])
        
        if let primaryKey = UserDiaryRepository.shared.primaryKey {
            editData(content: content, dateText: dateText, primaryKey: primaryKey, titleText: titleText)
        } else {
            let content = content
            let date = dateText.toDateAlarm() ?? Date()
            let animalName = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue)
            
            let task = Diary(type: RealmDiaryType(rawValue: 1), date: date, regDate: Date(), animalName: animalName ?? "신원 미상", content: content, photo: "", alarmTitle: titleText)
            
            do {
                try UserDiaryRepository.shared.write(task)
            } catch {
                print("error: \(error)")
                let userInfo = ["class": "\(self)", "method": "\(#function)"]
                Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
            }
            
            inputDataIntoArrayToDate(date: currentDate.value)
            
            if date > Date() {
                print("date Future correct!")
                sendNotification(title: titleText, body: content, date: date, index: alarmTaskList.count - 1)
            }
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
        
        if date > Date() {
            sendNotification(title: titleText, body: content, date: date, index: alarmTaskList.count - 1)
        }
        
        UserDiaryRepository.shared.primaryKey = nil
    }
}
