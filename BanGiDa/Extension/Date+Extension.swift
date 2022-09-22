//
//  Date+Extension.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/23.
//

import Foundation

extension Date {
    var backupFileTitle: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "_yyMMdd_hh:mm:ss"
        return formatter.string(from: self)
    }
}
