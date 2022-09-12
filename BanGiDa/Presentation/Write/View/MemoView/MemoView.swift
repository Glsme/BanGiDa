//
//  WriteView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

class MemoView: BaseView {
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .bananaYellow
        return view
    }()
    
    let imageButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "photo"), for: .normal)
        view.tintColor = .black
        view.backgroundColor = .lightGray
        return view
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .bananaYellow
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        
        let spacing: CGFloat = 10
        view.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        [imageView, imageButton, textView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.65)
            make.centerX.equalTo(self)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        imageButton.snp.makeConstraints { make in
            make.width.height.equalTo(imageView.snp.width).multipliedBy(0.2)
            make.bottom.equalTo(imageView.snp.bottom).offset(-10)
            make.trailing.equalTo(imageView.snp.trailing).offset(-10)
        }
        
        textView.snp.makeConstraints { make in
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.9)
            make.top.equalTo(imageView.snp.bottom).offset(40)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
}
