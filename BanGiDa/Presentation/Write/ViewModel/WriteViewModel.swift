//
//  WriteViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit
import SnapKit

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
        
        let image = image
        let content = content
        let date = dateText.toDate() ?? Date()
        
        print(date)
        
        let task = Diary(type: RealmDiaryType(rawValue: currentIndex.value), date: date, regDate: Date(), animalName: "뱅돌이", content: content, photo: image)
        UserMemoRepository.shared.write(task)
    }
}
