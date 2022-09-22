//
//  SettingViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import Foundation

class SettingViewModel {
    
    let dataLabel = ["백업", "복구", "초기화"]
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
            switch indexPath.row {
            case 0:
                text = dataLabel[0]
            case 1:
                text = dataLabel[1]
            case 2:
                text = dataLabel[2]
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                text = appInfoLabel[0]
            default:
                break
            }
        }
        
        return text
    }
}
