//
//  HomeViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/09.
//

import Foundation
import Combine
import CoreGraphics

//MARK: - Home ViewModel

final class HomeViewModel {

    // MARK: - Dependencies

    @Injected private var fetchDiariesByDateUseCase: FetchDiariesByDateUseCase
    @Injected private var deleteDiaryUseCase: DeleteDiaryUseCase
    @Injected private var loadImageUseCase: LoadImageUseCase
    @Injected private var removeNotificationUseCase: RemoveNotificationUseCase
    @Injected private var requestNotificationAuthorizationUseCase: RequestNotificationAuthorizationUseCase
    @Injected private var userPreferencesUseCase: UserPreferencesUseCase

    // MARK: - Data

    var memoTaskList: [DiaryEntry] = []
    var alarmTaskList: [DiaryEntry] = []
    var growthTaskList: [DiaryEntry] = []
    var showerTaskList: [DiaryEntry] = []
    var hospitalTaskList: [DiaryEntry] = []
    var abnormalTaskList: [DiaryEntry] = []

    @Published var alarmPrivacy: Bool = false
    @Published var currentDate: Date = Date()
    @Published var currentDateString: String = ""

    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC+9")
        formatter.dateFormat = "yyyy.MM.dd EE"
        return formatter
    }()

    let dateAndTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd EE hh:mm a"
        return formatter
    }()

    // MARK: - Data Handling

    func inputDataIntoArrayToDate(date: Date) {
        let grouped = fetchDiariesByDateUseCase.execute(date: date)
        memoTaskList = grouped[.memo] ?? []
        alarmTaskList = grouped[.alarm] ?? []
        growthTaskList = grouped[.hospital] ?? []
        showerTaskList = grouped[.shower] ?? []
        hospitalTaskList = grouped[.pill] ?? []
        abnormalTaskList = grouped[.abnormal] ?? []
    }

    func fetchData() {
        inputDataIntoArrayToDate(date: currentDate)
    }

    func fetchEventCount(date: Date) -> Int {
        fetchDiariesByDateUseCase.executeFlat(date: date).count
    }

    func taskListFor(category: Category) -> [DiaryEntry] {
        switch category {
        case .memo: return memoTaskList
        case .alarm: return alarmTaskList
        case .growth: return growthTaskList
        case .shower: return showerTaskList
        case .hospital: return hospitalTaskList
        case .abnormal: return abnormalTaskList
        }
    }

    // MARK: - Actions

    func deleteDiary(_ entry: DiaryEntry) {
        do {
            try deleteDiaryUseCase.execute(entry: entry)
        } catch {
            print("HomeViewModel.deleteDiary error: \(error)")
        }
    }

    func removeNotification(identifier: String) {
        removeNotificationUseCase.execute(identifier: identifier)
    }

    func removeNotification(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        removeNotificationUseCase.execute(title: title, body: body, date: date, index: index, repeatRule: repeatRule)
    }

    func requestNotificationAuthorization() {
        Task {
            let granted = await requestNotificationAuthorizationUseCase.execute()
            await MainActor.run { self.alarmPrivacy = granted }
        }
    }

    func filterNotification() {
        if !alarmPrivacy {
            requestNotificationAuthorization()
        }
    }

    func isFirstLaunchCompleted() -> Bool {
        userPreferencesUseCase.isFirstLaunchCompleted()
    }

    func loadImageData(for entry: DiaryEntry) -> Data? {
        guard let fileName = entry.photoFileName else { return nil }
        return loadImageUseCase.execute(fileName: fileName)
    }

    // MARK: - Table View Helpers

    func checkNumberOfRowsInsection(section: Int) -> Int {
        guard let category = Category(rawValue: section) else { return 0 }
        return taskListFor(category: category).count
    }

    func setHeaderHeight(section: Int) -> CGFloat {
        let height: CGFloat = 66
        guard let category = Category(rawValue: section) else { return 0 }
        return taskListFor(category: category).isEmpty ? 0 : height
    }
}
