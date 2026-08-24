//
//  NotificationRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation
import UserNotifications
import Domain

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

    func schedule(identifier: String, title: String, body: String, date: Date, repeatRule: AlarmRepeat) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents(for: date, repeatRule: repeatRule),
            repeats: repeatRule != .none
        )
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        notificationCenter.add(request)
    }

    func schedule(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        let identifier = title + body + "\(date) \(index) \(repeatRule.rawValue)"
        schedule(identifier: identifier, title: title, body: body, date: date, repeatRule: repeatRule)
    }

    func remove(identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func remove(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        let legacyIdentifier = title + body + "\(date) \(index)"
        let newIdentifier = title + body + "\(date) \(index) \(repeatRule.rawValue)"
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [legacyIdentifier, newIdentifier])
    }

    private func dateComponents(for date: Date, repeatRule: AlarmRepeat) -> DateComponents {
        let calendar = Calendar.current
        let base = calendar.dateComponents([.year, .month, .day, .hour, .minute, .weekday], from: date)

        var components = DateComponents()
        switch repeatRule {
        case .none:
            components.year = base.year
            components.month = base.month
            components.day = base.day
            components.hour = base.hour
            components.minute = base.minute
        case .daily:
            components.hour = base.hour
            components.minute = base.minute
        case .weekly:
            components.weekday = base.weekday
            components.hour = base.hour
            components.minute = base.minute
        case .monthly:
            components.day = base.day
            components.hour = base.hour
            components.minute = base.minute
        case .yearly:
            components.month = base.month
            components.day = base.day
            components.hour = base.hour
            components.minute = base.minute
        }
        return components
    }

    func removeAllDelivered() {
        notificationCenter.removeAllDeliveredNotifications()
    }

    func removeAllPending() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
}
