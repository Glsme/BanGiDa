//
//  WalkThroughViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/22.
//

import UIKit

class WalkthroughViewModel: CommonViewModel {
    func saveDescriptionData() {
        let animalName = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue)
        let task = Diary(type: RealmDiaryType(rawValue: 0),
                         date: Date(),
                         regDate: Date(),
                         animalName: animalName ?? "신원 미상",
                         content: """
                         상단의 버튼을 클릭하여 메모를 작성해보세요!
                         오른쪽으로 쓸어서 삭제할 수 있습니다.
                         """,
                         photo: "",
                         alarmTitle: nil)
        
        UserDiaryRepository.shared.write(task)
    }
}
