//
//  Category.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2023/01/01.
//

import UIKit

enum Category: Int, CaseIterable {
    case memo = 0
    case alarm
    case growth
    case shower
    case hospital
    case abnormal
    
    var title: String {
        switch self {
        case .memo: return "메모"
        case .alarm: return "알람"
        case .growth: return "성장 일기"
        case .shower: return "목욕"
        case .hospital: return "진료 기록/ 약"
        case .abnormal: return "이상 증상"
        }
    }
    
    var image: String {
        switch self {
        case .memo: return "note.text"
        case .alarm: return "alarm"
        case .growth: return "book.closed"
        case .shower: return "drop"
        case .hospital: return "cross.case"
        case .abnormal: return "bandage"
        }
    }
    
    var color: UIColor {
        switch self {
        case .memo: return UIColor(r: 133, g: 204, b: 204)
        case .alarm: return UIColor(r: 252, g: 200, b: 141)
        case .growth: return UIColor(r: 169, g: 223, b: 225)
        case .shower: return UIColor(r: 250, g: 227, b: 175)
        case .hospital: return UIColor(r: 168, g: 215, b: 177)
        case .abnormal: return UIColor(r: 228, g: 167, b: 180)
        }
    }
    
    var placeHolder: String {
        switch self {
        case .memo: return "오늘 있었던 일을 적어주세요."
        case .alarm: return "알람 메모를 적어주세요."
        case .growth: return "반려동물의 성장을 기록해주세요."
        case .shower: return "오늘 목욕할 때 있었던 일을 적어주세요."
        case .hospital: return "진료 기록 / 약 복용 기록을 적어주세요."
        case .abnormal: return "이상 증상을 적어주세요."
        }
    }
}
