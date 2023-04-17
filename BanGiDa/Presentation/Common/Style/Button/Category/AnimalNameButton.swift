//
//  AnimalNameButton.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/10/18.
//

import UIKit

final class AnimalNameButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureUI() {
        titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
    }
}
