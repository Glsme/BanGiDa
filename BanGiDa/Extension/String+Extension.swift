//
//  String+Extension.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/15.
//

import UIKit

extension String {
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 EEEE"
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "UTC+9")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
    
    func toDateAlarm() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.DD EE hh:mm a"
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "UTC+9")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}
