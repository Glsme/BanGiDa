//
//  WalkThroughViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import UIKit

final class WalkthroughViewModel: CommonViewModel {
    func saveDescriptionData() {
        let animalName = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue)
        let task = Diary(type: RealmDiaryType(rawValue: 0),
                         date: Date(),
                         regDate: Date(),
                         animalName: animalName ?? "신원 미상",
                         content: "상단의 버튼을 클릭하여\n메모를 작성해보세요!",
                         photo: "",
                         alarmTitle: nil)
        
        UserDiaryRepository.shared.write(task)
    }
}
