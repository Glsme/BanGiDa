//
//  MemoHeaderView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/16.
//

import UIKit
import SnapKit

class MemoHeaderView: BaseView {
    
    let circle: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        return view
    }()
    
    let headerLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont(name: FontList.jalnan.rawValue, size: 20)
        view.textColor = .systemTintColor
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    override func configureUI() {
        [circle, headerLabel].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        circle.snp.makeConstraints { make in
            make.centerY.equalTo(self.snp.centerY)
            make.leading.equalTo(self.snp.leading)
            make.width.height.equalTo(10)
        }
        
        headerLabel.snp.makeConstraints { make in
            make.centerY.equalTo(circle.snp.centerY)
            make.leading.equalTo(circle.snp.leading).offset(20)
        }
    }
}
