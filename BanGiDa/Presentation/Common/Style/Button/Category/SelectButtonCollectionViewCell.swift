//
//  HomeSelectCollectionViewCell.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import SnapKit

class SelectButtonCollectionViewCell: UICollectionViewCell {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
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
        self.addSubview(imageView)
    }
    
    func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.center.equalTo(self)
            make.height.width.equalTo(self).multipliedBy(0.5)
        }
    }
}

extension SelectButtonCollectionViewCell {
    func configureCell(bgColor: UIColor, image: String) {
        backgroundColor = bgColor
        clipsToBounds = true
        layer.cornerRadius = self.frame.height / 2
        imageView.image = UIImage(systemName: image) ?? UIImage()
        tintColor = .white
    }
}
