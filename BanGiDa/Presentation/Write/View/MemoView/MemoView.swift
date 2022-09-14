//
//  WriteView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

class MemoView: BaseView {
    
    let memoView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .bananaYellow
        view.layer.cornerRadius = 10
        return view
    }()
    
    let imageButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "photo"), for: .normal)
        view.tintColor = .black
        view.backgroundColor = .lightGray
        view.layer.cornerRadius = 25
        return view
    }()
    
    let dateButton: UIButton = {
        let view = UIButton()
        view.setTitle("날짜를 선택해주세요", for: .normal)
        view.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 12)
        view.setTitleColor(UIColor.black, for: .normal)
//        view.backgroundColor = .black
        return view
    }()
    
    let textView: UITextView = {
        let view = UITextView()
        view.backgroundColor = .bananaYellow
        view.font = UIFont(name: "HelveticaNeue-Medium", size: 16)
        view.layer.cornerRadius = 10
        let spacing: CGFloat = 10
        view.textContainerInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        view.textColor = .lightGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        self.addSubview(memoView)
        [imageView, imageButton, dateButton, textView].forEach {
            memoView.addSubview($0)
        }
    }
    
    override func setConstraints() {
        memoView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.6)
            make.centerX.equalTo(self)
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top).offset(20)
        }
        
        imageButton.snp.makeConstraints { make in
            make.width.height.equalTo(50)
            make.bottom.equalTo(imageView.snp.bottom).offset(-10)
            make.trailing.equalTo(imageView.snp.trailing).offset(-10)
        }
        
        dateButton.snp.makeConstraints { make in
            make.height.equalTo(20)
            make.width.equalTo(textView.snp.width)
            make.centerX.equalTo(self.safeAreaLayoutGuide)
            make.top.equalTo(imageView.snp.bottom).offset(20)
        }
        
        textView.snp.makeConstraints { make in
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.width.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.9)
            make.top.equalTo(dateButton.snp.bottom).offset(20)
            make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).offset(-10)
        }
    }
}
