//
//  CommonViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/15.
//

import UIKit
import RealmSwift

class CommonViewModel {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var memoTaskList: Results<Diary>!
    var alarmTaskList: Results<Diary>!
    var hospitalTaskList: Results<Diary>!
    var showerTaskList: Results<Diary>!
    var pillTaskList: Results<Diary>!
    var abnormalTaskList: Results<Diary>!
    
    var tasks: Results<Diary>!
    
    var alarmPrivacy: Observable<Bool> = Observable(false)
    var currentDate: Observable<Date> = Observable(Date())
    var currentDateString: Observable<String> = Observable("")
    
    let selectButtonList = [
        SelectButtonModel(title: "메모", imageString: "note.text", r: 133, g: 204, b: 204, alpha: 1, placeholder: "오늘 있었던 일을 적어주세요."),
        SelectButtonModel(title: "알람", imageString: "alarm", r: 252, g: 200, b: 141, alpha: 1, placeholder: "알람 메모를 적어주세요."),
        SelectButtonModel(title: "성장 일기", imageString: "book.closed", r: 169, g: 223, b: 225, alpha: 1, placeholder: "성장 일기를 적어주세요."),
        SelectButtonModel(title: "목욕", imageString: "drop", r: 250, g: 227, b: 175, alpha: 1, placeholder: "오늘 목욕할 때 있었던 일을 적어주세요."),
        SelectButtonModel(title: "진료 기록/ 약", imageString: "cross.case", r: 168, g: 215, b: 177, alpha: 1, placeholder: "진료 기록 / 약 복용 기록을 적어주세요."),
        SelectButtonModel(title: "이상 증상", imageString: "bandage", r: 228, g: 167, b: 180, alpha: 1, placeholder: "이상 증상을 적어주세요.")
    ]
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        //        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "UTC+9")
        formatter.dateFormat = "yyyy.MM.dd EE"
        return formatter
    }()
    
    let dateAndTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EE hh:mm a"
        //        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
    
    func setTableViewHeaderView(section: Int) -> UIView {
        let headerView = MemoHeaderView()
        //        headerView.backgroundColor = .green
        headerView.headerLabel.text = selectButtonList[section].title
        headerView.circle.backgroundColor = selectButtonList[section].color
        
        return headerView
    }
    
    func inputDataIntoArray() {
        memoTaskList = UserDiaryRepository.shared.filter(index: 0)
        alarmTaskList = UserDiaryRepository.shared.filter(index: 1)
        hospitalTaskList = UserDiaryRepository.shared.filter(index: 2)
        showerTaskList = UserDiaryRepository.shared.filter(index: 3)
        pillTaskList = UserDiaryRepository.shared.filter(index: 4)
        abnormalTaskList = UserDiaryRepository.shared.filter(index: 5)
    }
    
    func inputDataIntoArrayToDate(date: Date) {
        memoTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 0)
        alarmTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 1)
        hospitalTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 2)
        showerTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 3)
        pillTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 4)
        abnormalTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 5)
    }
    
    func fetchDate(date: Date) {
        UserDiaryRepository.shared.fetchDate(date: date)
    }
    
    //MARK: - Notification
    func requsetAuthorization() {
        let authorizations = UNAuthorizationOptions(arrayLiteral: .alert, .sound)
        
        notificationCenter.requestAuthorization(options: authorizations) { success, error in
            if success {
                print("alarm privacy succeed")
                self.alarmPrivacy.value = true
//                self.sendNotification(title: title, body: body, date: date, index: index)
            } else {
                print("alarm privacy failed")
                self.alarmPrivacy.value = false
            }
        }
    }
    
    func sendNotification(title: String, body: String, date: Date, index: Int) {
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = .default
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        print(components)
        let dateComponent = DateComponents(year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let request = UNNotificationRequest(identifier: title + body + "\(date) \(index)", content: notificationContent, trigger: trigger)
        
        notificationCenter.add(request)
        print("NotificationCenter Add Success")
    }
    
    func removeAllNotification() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
//    func removeNotification() {
//        notificationCenter
//    }
}
