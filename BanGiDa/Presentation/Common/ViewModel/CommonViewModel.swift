//
//  CommonViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/15.
//

import UIKit

import RealmSwift

public class CommonViewModel {
    
    let notificationCenter = UNUserNotificationCenter.current()
    
    var memoTaskList: Results<Diary>!
    var alarmTaskList: Results<Diary>!
    var growthTaskList: Results<Diary>!
    var showerTaskList: Results<Diary>!
    var hospitalTaskList: Results<Diary>!
    var abnormalTaskList: Results<Diary>!
    
    var tasks: Results<Diary>!
    
    var alarmPrivacy: Observable<Bool> = Observable(false)
    var currentDate: Observable<Date> = Observable(Date())
    var currentDateString: Observable<String> = Observable("")
    
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
    
    //MARK: - Data Handling
    
    func inputDataIntoArray() {
        print(#function)
        memoTaskList = UserDiaryRepository.shared.filter(index: 0)
        alarmTaskList = UserDiaryRepository.shared.filter(index: 1)
        growthTaskList = UserDiaryRepository.shared.filter(index: 2)
        showerTaskList = UserDiaryRepository.shared.filter(index: 3)
        hospitalTaskList = UserDiaryRepository.shared.filter(index: 4)
        abnormalTaskList = UserDiaryRepository.shared.filter(index: 5)
    }
    
    func inputDataIntoArrayToDate(date: Date) {
        memoTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 0)
        alarmTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 1)
        growthTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 2)
        showerTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 3)
        hospitalTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 4)
        abnormalTaskList = UserDiaryRepository.shared.filterToDate(date: date, index: 5)
    }
    
    func fetchData() {
        inputDataIntoArrayToDate(date: currentDate.value)
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
    
    func sendNotification(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat = .none) {
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.title = title
        notificationContent.body = body
        notificationContent.sound = .default
        
        let calendar = Calendar.current
        let baseComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: date)
        
        var dateComponent = DateComponents()
        switch repeatRule {
        case .none:
            dateComponent.year = baseComponents.year
            dateComponent.month = baseComponents.month
            dateComponent.day = baseComponents.day
            dateComponent.hour = baseComponents.hour
            dateComponent.minute = baseComponents.minute
        case .daily:
            dateComponent.hour = baseComponents.hour
            dateComponent.minute = baseComponents.minute
        case .weekly:
            dateComponent.weekday = baseComponents.weekday
            dateComponent.hour = baseComponents.hour
            dateComponent.minute = baseComponents.minute
        case .monthly:
            dateComponent.day = baseComponents.day
            dateComponent.hour = baseComponents.hour
            dateComponent.minute = baseComponents.minute
        case .yearly:
            dateComponent.month = baseComponents.month
            dateComponent.day = baseComponents.day
            dateComponent.hour = baseComponents.hour
            dateComponent.minute = baseComponents.minute
        }
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: repeatRule != .none)
        
        let request = UNNotificationRequest(
            identifier: title + body + "\(date) \(index) \(repeatRule.rawValue)",
            content: notificationContent,
            trigger: trigger
        )
        
        notificationCenter.add(request)
        print("NotificationCenter Add Success")
    }
    
    func removeAllNotification() {
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func removeNotification(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat = .none) {
        // 기존(반복 미포함) 식별자와 새(반복 포함) 식별자를 모두 제거해 호환 유지
        let legacyIdentifier = title + body + "\(date) \(index)"
        let newIdentifier = title + body + "\(date) \(index) \(repeatRule.rawValue)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [legacyIdentifier, newIdentifier])
    }
    
    func filterNotification() {
        if !alarmPrivacy.value {
            requsetAuthorization()
        }
    }

}
