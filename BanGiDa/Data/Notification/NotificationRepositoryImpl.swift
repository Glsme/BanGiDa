//
//  NotificationRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import UserNotifications

final class NotificationRepositoryImpl: NotificationRepository {
    private let notificationCenter: UNUserNotificationCenter

    init(notificationCenter: UNUserNotificationCenter = .current()) {
        self.notificationCenter = notificationCenter
    }

    func requestAuthorization() async -> Bool {
        let options: UNAuthorizationOptions = [.alert, .sound]
        do {
            return try await notificationCenter.requestAuthorization(options: options)
        } catch {
            return false
        }
    }

    func schedule(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

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

        let identifier = title + body + "\(date) \(index) \(repeatRule.rawValue)"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        notificationCenter.add(request)
    }

    func remove(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        let legacyIdentifier = title + body + "\(date) \(index)"
        let newIdentifier = title + body + "\(date) \(index) \(repeatRule.rawValue)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [legacyIdentifier, newIdentifier])
    }

    func removeAllDelivered() {
        notificationCenter.removeAllDeliveredNotifications()
    }

    func removeAllPending() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
