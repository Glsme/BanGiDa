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
        dateFormatter.dateFormat = "yyyy.MM.dd EE"
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
        dateFormatter.dateFormat = "yyyy.MM.dd EE hh:mm a"
//        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "UTC+9")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }
}
