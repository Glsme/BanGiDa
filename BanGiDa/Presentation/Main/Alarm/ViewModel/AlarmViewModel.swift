//
//  AlarmViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/19.
//

import Combine
import Foundation

final class AlarmViewModel {
    @Injected private var analyticsRepository: AnalyticsRepository
    @Injected private var saveAlarmUseCase: SaveAlarmUseCase
    @Injected private var updateDiaryUseCase: UpdateDiaryUseCase
    @Injected private var scheduleNotificationUseCase: ScheduleNotificationUseCase
    @Injected private var removeNotificationUseCase: RemoveNotificationUseCase
    @Injected private var fetchDiariesByDateUseCase: FetchDiariesByDateUseCase
    @Injected private var findDiaryByIDUseCase: FindDiaryByIDUseCase
    @Injected private var userPreferencesUseCase: UserPreferencesUseCase
    @Injected private var requestNotificationAuthorizationUseCase: RequestNotificationAuthorizationUseCase

    let dateText = CurrentValueSubject<String, Never>("")
    let diaryContent = CurrentValueSubject<String, Never>("")

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

    var currentDate: Date = Date()
    var alarmPrivacy: Bool = false
    var alarmTaskList: [DiaryEntry] = []

    var editingEntryID: String?

    func saveData(content: String, dateText: String, titleText: String, repeatRule: AlarmRepeat) {
        analyticsRepository.logEvent("SaveAlarm", parameters: [
          "name": "BangiDaLog",
          "full_text": "Save Alarm",
        ])

        if let editingEntryID, let existing = findDiaryByIDUseCase.execute(id: editingEntryID) {
            let date = dateText.toDateAlarm() ?? Date()

            var updatedEntry = existing
            updatedEntry.date = date
            updatedEntry.registeredDate = Date()
            updatedEntry.content = content
            updatedEntry.alarmTitle = titleText
            updatedEntry.repeatRule = repeatRule

            do {
                try updateDiaryUseCase.execute(entry: updatedEntry, photoData: nil)
            } catch {
                print("error: \(error)")
                let userInfo = ["class": "\(self)", "method": "\(#function)"]
                analyticsRepository.recordError(error, userInfo: userInfo)
            }

            fetchData(date: currentDate)

            removeNotificationUseCase.execute(identifier: existing.id)
            if date > Date() {
                scheduleNotificationUseCase.execute(
                    identifier: existing.id,
                    title: titleText,
                    body: content,
                    date: date,
                    repeatRule: repeatRule
                )
            }
        } else {
            let date = dateText.toDateAlarm() ?? Date()
            let animalName = userPreferencesUseCase.getPetName() ?? "신원 미상"

            do {
                _ = try saveAlarmUseCase.execute(
                    date: date,
                    content: content,
                    animalName: animalName,
                    alarmTitle: titleText,
                    repeatRule: repeatRule
                )
            } catch {
                print("error: \(error)")
                let userInfo = ["class": "\(self)", "method": "\(#function)"]
                analyticsRepository.recordError(error, userInfo: userInfo)
            }

            fetchData(date: currentDate)
        }
    }

    func fetchData(date: Date) {
        let grouped = fetchDiariesByDateUseCase.execute(date: date)
        alarmTaskList = grouped[.alarm] ?? []
    }

    func requestAuthorization() {
        Task { [weak self] in
            guard let self = self else { return }
            let granted = await self.requestNotificationAuthorizationUseCase.execute()
            await MainActor.run { [weak self] in
                self?.alarmPrivacy = granted
            }
        }
    }
}
