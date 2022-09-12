//
//  HomeSelectCollectionViewCell.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import SnapKit

class HomeSelectCollectionViewCell: UICollectionViewCell {
    
    let selectButton: UIButton = {
        let view = UIButton()
        view.backgroundColor = .clear
        view.clipsToBounds = true
        view.sizeToFit()
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
        setConstraints()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureUI() {
        self.addSubview(selectButton)
    }
    
    func setConstraints() {
        selectButton.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
    
}
