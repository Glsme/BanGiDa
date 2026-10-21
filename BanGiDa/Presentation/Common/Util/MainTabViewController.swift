//
//  MainTabViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2023/01/02.
//

import UIKit
import SwiftUI

final class MainTabViewController: UITabBarController {
    // setViewControllers 순서와 묶여 있으므로 탭을 추가·재배치하면 함께 고쳐야 한다.
    enum Tab: Int {
        case home
        case search
        case story
        case setting
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        let homeVC = UINavigationController(rootViewController: HomeViewViewController())
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        let storyVC = UIHostingController(rootView: StoryView())
        let settingVC = UINavigationController(rootViewController: SettingViewController())
        
        setViewControllers([homeVC, searchVC, storyVC, settingVC], animated: true)
        tabBar.tintColor = .red
        
        if #available(iOS 26.0, *) {
            tabBar.backgroundColor = .clear
        } else {
            tabBar.backgroundColor = .tabBarColor
        }
        
        if let items = tabBar.items {
            setImage(of: items[0], systemName: "square.and.pencil")
            setImage(of: items[1], systemName: "magnifyingglass")
            setImage(of: items[2], systemName: "photo.on.rectangle.angled")
            setImage(of: items[3], systemName: "gearshape")
        }
    }

    // iPhone Duo의 측면 세로 바는 tabBar.tintColor를 따르지 않고 기본 강조색(파랑)으로 그린다.
    // 선택 아이콘에 색을 직접 입혀 가로·세로 바 모두 같은 강조색을 쓰게 한다.
    private func setImage(of item: UITabBarItem, systemName: String) {
        item.image = UIImage(systemName: systemName)
        item.selectedImage = UIImage(systemName: systemName)?
            .withTintColor(.red, renderingMode: .alwaysOriginal)
    }
}
