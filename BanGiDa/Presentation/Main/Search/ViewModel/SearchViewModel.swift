//
//  SearchViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import Combine
import Foundation

final class SearchViewModel {

    @Injected private var searchDiariesUseCase: SearchDiariesUseCase
    @Injected private var deleteDiaryUseCase: DeleteDiaryUseCase
    @Injected private var loadImageUseCase: LoadImageUseCase
    @Injected private var removeNotificationUseCase: RemoveNotificationUseCase

    var isFiltering = false
    var currentIndex = CurrentValueSubject<Int?, Never>(nil)

    var memoTaskList: [DiaryEntry] = []
    var alarmTaskList: [DiaryEntry] = []
    var growthTaskList: [DiaryEntry] = []
    var showerTaskList: [DiaryEntry] = []
    var hospitalTaskList: [DiaryEntry] = []
    var abnormalTaskList: [DiaryEntry] = []

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

    func checkNumberOfRowsInsection(section: Int) -> Int {
        if let index = currentIndex.value {
            switch index {
            case 0: return memoTaskList.count
            case 1: return alarmTaskList.count
            case 2: return growthTaskList.count
            case 3: return showerTaskList.count
            case 4: return hospitalTaskList.count
            case 5: return abnormalTaskList.count
            default: return 0
            }
        } else {
            return 0
        }
    }

    func inputDataIntoArray() {
        memoTaskList = searchDiariesUseCase.execute(type: DiaryType(rawValue: 0)!)
        alarmTaskList = searchDiariesUseCase.execute(type: DiaryType(rawValue: 1)!)
        growthTaskList = searchDiariesUseCase.execute(type: DiaryType(rawValue: 2)!)
        showerTaskList = searchDiariesUseCase.execute(type: DiaryType(rawValue: 3)!)
        hospitalTaskList = searchDiariesUseCase.execute(type: DiaryType(rawValue: 4)!)
        abnormalTaskList = searchDiariesUseCase.execute(type: DiaryType(rawValue: 5)!)
    }

    func deleteDiary(_ entry: DiaryEntry) {
        try? deleteDiaryUseCase.execute(entry: entry)
    }

    func removeNotification(title: String, body: String, date: Date, index: Int, repeatRule: AlarmRepeat) {
        removeNotificationUseCase.execute(title: title, body: body, date: date, index: index, repeatRule: repeatRule)
    }

    func loadImage(id: String) -> Data? {
        loadImageUseCase.execute(fileName: "\(id).jpg")
    }

    func taskListFor(index: Int) -> [DiaryEntry] {
        switch index {
        case 0: return memoTaskList
        case 1: return alarmTaskList
        case 2: return growthTaskList
        case 3: return showerTaskList
        case 4: return hospitalTaskList
        case 5: return abnormalTaskList
        default: return []
        }
    }
}
