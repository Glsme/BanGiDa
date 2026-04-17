//
//  WalkThroughViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import Foundation

final class WalkthroughViewModel {
    @Injected private var analyticsRepository: AnalyticsRepository
    @Injected private var updateNicknameUseCase: UpdateNicknameUseCase
    @Injected private var saveDiaryUseCase: SaveDiaryUseCase
    @Injected private var userPreferencesUseCase: UserPreferencesUseCase

    func saveDescriptionData() {
        let petName = userPreferencesUseCase.getPetName()

        do {
            try saveDiaryUseCase.execute(
                type: .memo,
                date: Date(),
                content: "상단의 버튼을 클릭하여\n메모를 작성해보세요!",
                animalName: petName ?? "신원 미상",
                photoData: nil,
                alarmTitle: nil,
                repeatRule: .none
            )
        } catch {
            print("error \(error)")
            let userInfo = ["class": "\(self)", "method": "\(#function)"]
            analyticsRepository.recordError(error, userInfo: userInfo)
        }
    }

    func update(nickname: String) {
        Task {
            do {
                try await updateNicknameUseCase.execute(nickname)
            } catch {
                print("\(#function) error: \(error)")
            }
        }
    }

    func savePetName(_ name: String) {
        userPreferencesUseCase.setPetName(name)
    }

    func setFirstLaunchCompleted() {
        userPreferencesUseCase.setFirstLaunchCompleted()
    }
}
