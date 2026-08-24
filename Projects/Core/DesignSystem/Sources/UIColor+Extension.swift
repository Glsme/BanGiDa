//
//  UIColor+Extension.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/12.
//

import UIKit

extension UIColor {
    package static let bananaYellow = UIColor(red: 255/255, green: 248/255, blue: 195/255, alpha: 1)
    package static let skyMint = UIColor(red: 157/255, green: 208/255, blue: 221/255, alpha: 1)
    package static let ultraLightGray = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
    package static let unaBlue = UIColor(red: 26/255, green: 198/255, blue: 255/255, alpha: 1)
    package static let skyBlue = UIColor(red: 169/255, green: 223/255, blue: 225/255, alpha: 1)
    package static let greenblue = UIColor(red: 133/255, green: 204/255, blue: 204/255, alpha: 1)
    package static let pastelYellow = UIColor(red: 250/255, green: 227/255, blue: 175/255, alpha: 1)
    package static let softGray = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
    package static let backgroundColor = UIColor(named: "BackgroundColor")
    package static let systemTintColor = UIColor(named: "SystemTintColor")
    package static let memoBackgroundColor = UIColor(named: "MemoBackgorundColor")
    package static let memoDarkGray = UIColor(named: "MemoDateColor")
    package static let tabBarColor = UIColor(named: "TabBarColor")
    package static let darkPink = UIColor(red: 228/255, green: 167/255, blue: 180/255, alpha: 1)
    
    package convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(
            red: CGFloat(r / 255),
            green: CGFloat(g / 255),
            blue: CGFloat(b / 255),
            alpha: alpha
        )
    }
}
