//
//  MainTabViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2023/01/02.
//

import UIKit

class MainTabViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    func configureUI() {
        let homeVC = UINavigationController(rootViewController: HomeViewViewController())
        let searchVC = UINavigationController(rootViewController: SearchViewController())
        let settingVC = UINavigationController(rootViewController: SettingViewController())
        
        setViewControllers([homeVC, searchVC, settingVC], animated: true)
        tabBar.tintColor = .red
        tabBar.backgroundColor = .tabBarColor
        
        if let items = tabBar.items {
            items[0].image = UIImage(systemName: "square.and.pencil")
            items[1].image = UIImage(systemName: "magnifyingglass")
            items[2].image = UIImage(systemName: "gearshape")
        }
    }
}
