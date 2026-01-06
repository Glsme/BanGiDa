//
//  MainTabViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2023/01/02.
//

import UIKit
import SwiftUI

final class MainTabViewController: UITabBarController {
    
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
            items[0].image = UIImage(systemName: "square.and.pencil")
            items[1].image = UIImage(systemName: "magnifyingglass")
            items[2].image = UIImage(systemName: "photo.on.rectangle.angled")
            items[3].image = UIImage(systemName: "gearshape")
        }
    }
}
