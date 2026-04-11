//
//  NotificationRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/04/10.
//

import Foundation

protocol NotificationRepository {
    func requestAuthorization() async -> Bool
    func schedule(identifier: String, title: String, body: String, date: Date, repeatRule: AlarmRepeat)
    func schedule(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat)
    func remove(identifier: String)
    func remove(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat)
    func removeAllDelivered()
    func removeAllPending()
}
