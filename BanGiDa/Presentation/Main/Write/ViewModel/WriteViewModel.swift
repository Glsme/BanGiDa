//
//  WriteViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import Combine
import Foundation

import SnapKit
import RealmSwift

final class WriteViewModel: CommonViewModel {
    let currentIndex = CurrentValueSubject<Int, Never>(0)
    let dateText = CurrentValueSubject<String, Never>("")
    let diaryContent = CurrentValueSubject<String, Never>("")
    
    func setCurrentMemoType() -> SelectButtonModel {
        return selectButtonList[self.currentIndex.value]
    }
    
    func saveData(image: Data?, content: String, dateText: String) {
        if let primaryKey = UserDiaryRepository.shared.primaryKey {
            editData(image: image, content: content, dateText: dateText, primaryKey: primaryKey)
        } else {
            let image = image
            let content = content
            let date = dateText.toDate() ?? Date()
            let animalName = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue)
            
            let task = Diary(type: RealmDiaryType(rawValue: currentIndex.value), date: date, regDate: Date(), animalName: animalName ?? "신원 미상", content: content, photo: "", alarmTitle: nil)
            UserDiaryRepository.shared.write(task)
            
            if let image = image {
                UserDiaryRepository.shared.documentManager
                    .saveImageFromDocument(fileName: "\(task.objectId).jpg", imageData: image)
            }
        }
    }
    
    func editData(image: Data?, content: String, dateText: String, primaryKey: ObjectId) {
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
        
        UserDiaryRepository.shared.update(task, date: date, regDate: regDate, content: content, image: "", alarmTitle: nil)
        UserDiaryRepository.shared.primaryKey = nil
        
        if let image = image {
            UserDiaryRepository.shared.documentManager
                .saveImageFromDocument(fileName: "\(task.objectId).jpg", imageData: image)
        }
    }
}
