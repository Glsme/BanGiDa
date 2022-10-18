//
//  AnimalNameCollectionViewCell.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/10/18.
//

import UIKit
import SnapKit

class AnimalNameCollectionViewCell: UICollectionViewCell {
    let nameButton: UIButton = {
       let view = UIButton()
        view.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 12)
        view.backgroundColor = .greenblue
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
        self.addSubview(nameButton)
    }
    
    func setConstraints() {
        nameButton.snp.makeConstraints { make in
            make.edges.equalTo(self)
        }
    }
}
