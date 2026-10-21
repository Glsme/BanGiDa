//
//  UINavigationItem+Extension.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/10/19.
//

import UIKit

extension UINavigationItem {
    // iPhone Duo는 바를 측면 세로 축에 놓을 때 심볼이 있는 아이템만 세로로 배치하고,
    // Done 같은 주요 동작은 고정 trailing 그룹에 두도록 권장한다(HIG — Designing for iPhone Duo).
    // 심볼은 기기·버전과 관계없이 같은 모양으로 보이도록 항상 지정하고, 제목은 VoiceOver·오버플로 메뉴용으로 남긴다.
    func setPrimaryActionItem(_ item: UIBarButtonItem, systemImageName: String) {
        item.image = UIImage(systemName: systemImageName)

        if #available(iOS 27.1, *) {
            pinnedTrailingGroup = item.creatingFixedGroup()
        } else {
            rightBarButtonItem = item
        }
    }
}
