//
//  WriteViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import Combine
import Foundation
import CoreKit
import Domain

final class WriteViewModel {
    @Injected private var analyticsRepository: AnalyticsRepository
    @Injected private var saveDiaryUseCase: SaveDiaryUseCase
    @Injected private var updateDiaryUseCase: UpdateDiaryUseCase
    @Injected private var saveImageUseCase: SaveImageUseCase
    @Injected private var findDiaryByIDUseCase: FindDiaryByIDUseCase
    @Injected private var userPreferencesUseCase: UserPreferencesUseCase

    let currentIndex = CurrentValueSubject<Int, Never>(0)
    let dateText = CurrentValueSubject<String, Never>("")
    let diaryContent = CurrentValueSubject<String, Never>("")
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        //        formatter.locale = Locale(identifier: "ko_KR")
        formatter.timeZone = TimeZone(identifier: "UTC+9")
        formatter.dateFormat = "yyyy.MM.dd EE"
        return formatter
    }()

    var editingEntryID: String?

    func saveData(image: Data?, content: String, dateText: String) {
        analyticsRepository.logEvent("SaveData", parameters: [
          "name": "BangiDaLog",
          "full_text": "Save Data",
        ])

        if let editingEntryID, let existing = findDiaryByIDUseCase.execute(id: editingEntryID) {
            var updatedEntry = existing
            updatedEntry.date = dateText.toDate() ?? Date()
            updatedEntry.registeredDate = Date()
            updatedEntry.content = content

            do {
                try updateDiaryUseCase.execute(entry: updatedEntry, photoData: image)
            } catch {
                print("error: \(error)")

                let parameter: [String: Any] = [
                    "object": "\(self)",
                    "error": "\(error)",
                    "method": #function,
                ]

                analyticsRepository.logEvent("Memo Edit Error", parameters: parameter)
            }
        } else {
            let date = dateText.toDate() ?? Date()
            let animalName = userPreferencesUseCase.getPetName() ?? "신원 미상"

            guard let diaryType = DiaryType(rawValue: currentIndex.value) else {
                print("error: Invalid diary type for index \(currentIndex.value)")
                return
            }

            do {
                _ = try saveDiaryUseCase.execute(
                    type: diaryType,
                    date: date,
                    content: content,
                    animalName: animalName,
                    photoData: image,
                    alarmTitle: nil,
                    repeatRule: .none
                )
            } catch {
                print("error: \(error)")

                var parameter: [String: Any] = [
                    "object": "\(self)",
                    "error": "\(error)",
                    "method": #function,
                ]

                parameter["type"] = currentIndex.value

                analyticsRepository.logEvent("Memo Saving Error", parameters: parameter)
            }
        }
    }
}
