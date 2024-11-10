//
//  UIViewController+Extension.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/10.
//

import UIKit

extension UIViewController {
    enum TransitionType {
        case push
        case presentNavigation
        case presentFullScreenNavigation
        case present
        case presentFullscreen
        case fade
    }
    
    func transViewController<T: UIViewController>(ViewController vc: T, type: TransitionType) {
        switch type {
        case .push:
            self.navigationController?.pushViewController(vc, animated: true)
        case .present:
            present(vc, animated: true)
        case .presentNavigation:
            let navi = UINavigationController(rootViewController: vc)
            self.present(navi, animated: true)
        case .presentFullScreenNavigation:
            let navi = UINavigationController(rootViewController: vc)
            navi.modalPresentationStyle = .fullScreen
            self.present(navi, animated: true)
        case .presentFullscreen:
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        case .fade:
            vc.modalPresentationStyle = .overCurrentContext
            vc.modalTransitionStyle = .crossDissolve
            present(vc, animated: true)
        }
    }
}
