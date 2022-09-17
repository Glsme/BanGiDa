//
//  LineView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/18.
//

import UIKit

class LineView: BaseView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .darkGray
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}
