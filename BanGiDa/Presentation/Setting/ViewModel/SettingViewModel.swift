//
//  SettingViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import Foundation

final class SettingViewModel: CommonViewModel {
    
    let dataLabel = ["백업", "복구", "초기화"]
    let serviceLabel = ["리뷰 남기기", "문의하기"]
    let appInfoLabel = ["오픈소스 라이브러리", "버전 정보"]
    
    let settingTitleLabels = ["데이터", "서비스", "앱 정보"]
        
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let _ = dictionary["CFBundleVersion"] as? String else { return nil }

        let versionAndBuild: String = "\(version)"
        return versionAndBuild
    }
    
    public func setSectionHeaderView(section: Int) -> String {
        switch section {
        case 0:
            return "데이터"
        case 1:
            return "서비스"
        case 2:
            return "앱 정보"
        default:
            return ""
        }
    }
    
    public func setCellNumber(section: Int) -> Int {
        if section == 0 {
            return dataLabel.count
        } else if section == 1 {
            return serviceLabel.count
        } else if section == 2 {
            return appInfoLabel.count
        } else {
            return 0
        }
    }
    
    public func setCellText(indexPath: IndexPath) -> String {
        var text = ""
        
        if indexPath.section == 0 {
            text = dataLabel[indexPath.row]
        } else if indexPath.section == 1 {
            text = serviceLabel[indexPath.row]
        } else if indexPath.section == 2 {
            text = appInfoLabel[indexPath.row]
        }
        
        return text
    }
    
    public func setNotifications() {
//        UserDiaryRepository.shared.fetch()
        inputDataIntoArray()
        
        var index = 0
        
        for item in alarmTaskList {
            if item.date > Date() {
                sendNotification(title: item.animalName, body: item.content, date: item.date, index: index)
            }
            
            index += 1
        }
    }
    
    public func resetData() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.first.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.name.rawValue)
        UserDiaryRepository.shared.deleteAll()
        removeAllNotification()
    }
}
