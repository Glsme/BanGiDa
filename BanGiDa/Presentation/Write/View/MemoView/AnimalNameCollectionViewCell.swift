//
//  AnimalNameCollectionViewCell.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/10/18.
//

import UIKit
import SnapKit

final class AnimalNameCollectionViewCell: UICollectionViewCell {
    let nameButton: AnimalNameButton = {
       let view = AnimalNameButton()
        view.backgroundColor = .memoDarkGray
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
        contentView.addSubview(nameButton)
    }
    
    func setConstraints() {
        nameButton.snp.makeConstraints { make in
            make.edges.equalTo(contentView.snp.edges)
        }
    }
}
