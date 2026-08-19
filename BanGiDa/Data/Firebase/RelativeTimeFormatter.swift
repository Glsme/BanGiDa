//
//  RelativeTimeFormatter.swift
//  BanGiDa
//

import Foundation

enum RelativeTimeFormatter {
    // DateFormatter 생성 비용이 크므로 한 번만 만들어 재사용한다.
    private static let fallbackDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter
    }()

    static func formattedTime(from createdAt: Date, now: Date = Date()) -> String {
        let interval = max(0, now.timeIntervalSince(createdAt))

        if interval < 60 {
            return "방금 전"
        }

        if interval < 3600 {
            let minutes = Int(interval / 60)
            return "\(minutes)분 전"
        }

        if interval < 86400 {
            let hours = Int(interval / 3600)
            return "\(hours)시간 전"
        }

        if interval < 604800 {
            let days = Int(interval / 86400)
            return "\(days)일 전"
        }

        return fallbackDateFormatter.string(from: createdAt)
    }
}
