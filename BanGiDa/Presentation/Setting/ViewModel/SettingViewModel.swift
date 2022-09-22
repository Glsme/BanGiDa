//
//  SettingViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import Foundation

class SettingViewModel {
    
    let dataLabel = ["반려 동물 변경", "백업", "복구", "초기화"]
    let appInfoLabel = ["앱 정보"]
    
    func setSectionHeaderView(section: Int) -> String {
        switch section {
        case 0:
            return "데이터"
        case 1:
            return "앱 정보"
        default:
            return ""
        }
    }
    
    func setCellNumber(section: Int) -> Int {
        if section == 0 {
            return dataLabel.count
        } else if section == 1 {
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
            text = appInfoLabel[indexPath.row]
        }
        
        return text
    }
}
