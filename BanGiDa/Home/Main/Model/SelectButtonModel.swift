//
//  SelectButtonModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/12.
//

import UIKit

struct SelectButtonModel {
    let title: String
    let image: UIImage
    let color: UIColor
    
    /// R, G, B Input 0 ~ 255
    init(title: String, imageString: String, r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat) {
        self.title = title
        
        let config = UIImage.SymbolConfiguration(pointSize: 22, weight: .regular, scale: .default)
        self.image = UIImage(systemName: imageString, withConfiguration: config) ?? UIImage()
        
        let red: CGFloat = r/255
        let green: CGFloat = g/255
        let blue: CGFloat = b/255
        let alpha: CGFloat = alpha
        
        self.color = UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}
