import Foundation

@testable import BanGiDa

struct ScheduledNotification {
    let identifier: String
    let title: String
    let body: String
    let date: Date
    let repeatRule: AlarmRepeat
}

struct ScheduledNotificationByIndex {
    let title: String
    let body: String
    let date: Date
    let index: Int
    let repeatRule: AlarmRepeat
}

struct RemovedNotificationByIndex {
    let title: String
    let body: String
    let date: Date
    let index: Int
    let repeatRule: AlarmRepeat
}

final class MockNotificationRepository: NotificationRepository {
    var requestAuthorizationReturnValue = false
    /// DiaryRepository와의 호출 순서를 함께 검증하기 위한 공유 레코더 (DiaryTestDoubles.swift의 CallRecorder).
    var callRecorder: CallRecorder?

    private(set) var requestAuthorizationCallCount = 0
    private(set) var scheduledNotifications: [ScheduledNotification] = []
    private(set) var scheduledNotificationsByIndex: [ScheduledNotificationByIndex] = []
    private(set) var removedIdentifiers: [String] = []
    private(set) var removedNotificationsByIndex: [RemovedNotificationByIndex] = []
    private(set) var removeAllDeliveredCallCount = 0
    private(set) var removeAllPendingCallCount = 0

    func requestAuthorization() async -> Bool {
        requestAuthorizationCallCount += 1
        return requestAuthorizationReturnValue
    }

    func schedule(identifier: String, title: String, body: String, date: Date, repeatRule: AlarmRepeat) {
        callRecorder?.record("schedule")
        scheduledNotifications.append(
            ScheduledNotification(identifier: identifier, title: title, body: body, date: date, repeatRule: repeatRule)
        )
    }

    func schedule(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        callRecorder?.record("scheduleByIndex")
        scheduledNotificationsByIndex.append(
            ScheduledNotificationByIndex(title: title, body: body, date: date, index: index, repeatRule: repeatRule)
        )
    }

    func remove(identifier: String) {
        callRecorder?.record("remove")
        removedIdentifiers.append(identifier)
    }

    func remove(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        callRecorder?.record("removeByIndex")
        removedNotificationsByIndex.append(
            RemovedNotificationByIndex(title: title, body: body, date: date, index: index, repeatRule: repeatRule)
        )
    }

    func removeAllDelivered() {
        callRecorder?.record("removeAllDelivered")
        removeAllDeliveredCallCount += 1
    }

    func removeAllPending() {
        callRecorder?.record("removeAllPending")
        removeAllPendingCallCount += 1
    }
}
