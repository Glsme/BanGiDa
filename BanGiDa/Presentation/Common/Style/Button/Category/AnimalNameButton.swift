//
//  AnimalNameButton.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/10/18.
//

import UIKit

class AnimalNameButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        circle()
    }
    
    func circle() {
        layer.cornerRadius = 10
        layer.masksToBounds = true
    }
    
    func configureUI() {
        
        
        titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
    }
}
