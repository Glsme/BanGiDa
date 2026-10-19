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
    func setPrimaryActionItem(_ item: UIBarButtonItem, systemImageName: String) {
        if #available(iOS 27.1, *) {
            item.image = UIImage(systemName: systemImageName)
            pinnedTrailingGroup = item.creatingFixedGroup()
        } else {
            rightBarButtonItem = item
        }
    }
}
