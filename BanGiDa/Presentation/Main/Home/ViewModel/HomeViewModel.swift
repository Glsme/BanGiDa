//
//  HomeViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/09.
//

import Foundation
import CoreGraphics

//MARK: - Home ViewModel

final class HomeViewModel {

    // MARK: - Dependencies

    @Injected private var fetchDiariesByDateUseCase: FetchDiariesByDateUseCase
    @Injected private var deleteDiaryUseCase: DeleteDiaryUseCase
    @Injected private var loadImageUseCase: LoadImageUseCase
    @Injected private var removeNotificationUseCase: RemoveNotificationUseCase
    @Injected private var notificationRepository: NotificationRepository
    @Injected private var diaryRepository: DiaryRepository
    @Injected private var userPreferencesRepository: UserPreferencesRepository

    // MARK: - Data

    var memoTaskList: [DiaryEntry] = []
    var alarmTaskList: [DiaryEntry] = []
    var growthTaskList: [DiaryEntry] = []
    var showerTaskList: [DiaryEntry] = []
    var hospitalTaskList: [DiaryEntry] = []
    var abnormalTaskList: [DiaryEntry] = []

    var alarmPrivacy: Observable<Bool> = Observable(false)
    var currentDate: Observable<Date> = Observable(Date())
    var currentDateString: Observable<String> = Observable("")

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
        memoTaskList = diaryRepository.fetchByDateAndType(date: date, type: .memo)
        alarmTaskList = diaryRepository.fetchByDateAndType(date: date, type: .alarm)
        growthTaskList = diaryRepository.fetchByDateAndType(date: date, type: .hospital)
        showerTaskList = diaryRepository.fetchByDateAndType(date: date, type: .shower)
        hospitalTaskList = diaryRepository.fetchByDateAndType(date: date, type: .pill)
        abnormalTaskList = diaryRepository.fetchByDateAndType(date: date, type: .abnormal)
    }

    func fetchData() {
        inputDataIntoArrayToDate(date: currentDate.value)
    }

    func fetchEventCount(date: Date) -> Int {
        diaryRepository.fetchByDate(date).count
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
            let granted = await notificationRepository.requestAuthorization()
            await MainActor.run { self.alarmPrivacy.value = granted }
        }
    }

    func filterNotification() {
        if !alarmPrivacy.value {
            requestNotificationAuthorization()
        }
    }

    func isFirstLaunchCompleted() -> Bool {
        userPreferencesRepository.isFirstLaunchCompleted()
    }

    func loadImageData(id: String) -> Data? {
        loadImageUseCase.execute(fileName: "\(id).jpg")
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
