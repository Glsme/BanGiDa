//
//  HomeViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/09.
//

import UIKit
import FSCalendar
import RealmSwift

//MARK: - Home ViewModel

class HomeViewModel: CommonViewModel {
    
    var tasks: Results<UserDiary>! {
        didSet {
            print("Tasks Changed")
        }
    }
    
    var memoArray: Observable<[UserDiary]> = Observable([])
    var alarmArray: Observable<[UserDiary]> = Observable([])
    var hospitalArray: Observable<[UserDiary]> = Observable([])
    var showerArray: Observable<[UserDiary]> = Observable([])
    var pillArray: Observable<[UserDiary]> = Observable([])
    var abnormalArray: Observable<[UserDiary]> = Observable([])
    
    @objc func todayButtonClicked(calendar: FSCalendar) {
        calendar.setCurrentPage(Date(), animated: true)
    }
    
    func pushViewController(completion: @escaping () -> Void ) {
        completion()
    }
    
    func fetchData() {
        tasks = UserMemoRepository.shared.fetch()
    }
    
    func inputDataIntoArray() {
        
        for item in tasks {
            switch item.diaryType {
            case "memo":
                memoArray.value.append(item)
            case "alarm":
                alarmArray.value.append(item)
            case "hospital":
                hospitalArray.value.append(item)
            case "shower":
                showerArray.value.append(item)
            case "pill":
                pillArray.value.append(item)
            case "abnormal":
                abnormalArray.value.append(item)
            default:
                break
            }
        }
    }
}
