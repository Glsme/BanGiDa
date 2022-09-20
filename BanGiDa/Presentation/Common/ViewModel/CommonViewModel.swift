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
    
    let selectButtonList = [
        SelectButtonModel(title: "메모", imageString: "note.text", r: 133, g: 204, b: 204, alpha: 1, placeholder: "오늘 있었던 일을 적어주세요."),
        SelectButtonModel(title: "알람", imageString: "alarm", r: 252, g: 200, b: 141, alpha: 1, placeholder: "알람 메모를 적어주세요."),
        SelectButtonModel(title: "진료 기록", imageString: "cross.case", r: 169, g: 223, b: 225, alpha: 1, placeholder: "병원 진료를 적어주세요."),
        SelectButtonModel(title: "목욕", imageString: "drop", r: 250, g: 227, b: 175, alpha: 1, placeholder: "오늘 목욕할 때 있었던 일을 적어주세요."),
        SelectButtonModel(title: "약", imageString: "pills", r: 168, g: 215, b: 177, alpha: 1, placeholder: "약 복용 기록을 적어주세요."),
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
    
    //MARK: - Notification
    func requsetAuthorization() {
        let authorizations = UNAuthorizationOptions(arrayLiteral: .alert, .sound)
        
        for item in alarmTaskList {
            notificationCenter.requestAuthorization(options: authorizations) { success, error in
                if success {
//                    print(item.alarmTitle)
//                    print(item.date)
//                    print(item.content)
//                    self.sendNotification(title: item.alarmTitle ?? "반기다 알림", body: item.content, date: item.date)
//                    self.sendNotification(title: "되라제발", body: "제발", date: Date())
                }
            }
        }
    }
    
    func sendNotification(title: String, body: String, date: Date) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = title
        notificationContent.body = body
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        
        let dateComponent = DateComponents(year: components.year, month: components.month, day: components.day, hour: components.hour, minute: components.minute, second: 30)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponent, repeats: false)
        
        let request = UNNotificationRequest(identifier: "Hi", content: notificationContent, trigger: trigger)
        
        notificationCenter.add(request)
    }
}
