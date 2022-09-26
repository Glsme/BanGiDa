//
//  SettingViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import Foundation

class SettingViewModel: CommonViewModel {
    
    let dataLabel = ["백업", "복구", "초기화"]
    let serviceLabel = ["리뷰 남기기", "문의하기"]
    let appInfoLabel = ["오픈소스 라이브러리", "버전 정보"]
    
    func setSectionHeaderView(section: Int) -> String {
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
    
    func setCellNumber(section: Int) -> Int {
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
    
    func setCellText(indexPath: IndexPath) -> String {
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
    
    func setNotifications() {
        UserDiaryRepository.shared.fetch()
        inputDataIntoArray()
        
        var index = 0
        for item in alarmTaskList {
            if item.date > Date() {
                sendNotification(title: item.animalName, body: item.content, date: item.date, index: index)
            }
            
            index += 1
        }
    }
}
