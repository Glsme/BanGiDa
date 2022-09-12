//
//  HomeView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import SnapKit

class HomeView: BaseView {
    
    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
//    let imageView: UIImageView = {
//        let view = UIImageView()
//        view.backgroundColor = .darkGray
//        view.clipsToBounds = true
//        view.layer.cornerRadius = UIScreen.main.bounds.width * 0.2 / 2
//        return view
//    }()
    
//    let imageButton: UIButton = {
//        let view = UIButton()
//        view.setImage(UIImage(systemName: "plus"), for: .normal)
//        view.backgroundColor = .white
//        view.clipsToBounds = true
//        view.sizeToFit()
//        view.tintColor = .black
//        view.layer.cornerRadius = ((UIScreen.main.bounds.width * 0.2) - 10) / 2
//        return view
//    }()
    
    let selectCollectionView: HomeSelectCollectionView = {
        let view = HomeSelectCollectionView(frame: .zero, collectionViewLayout: selectCollectionViewLayout())
        
        return view
    }()
    
    let homeTableView: HomeTableView = {
        let view = HomeTableView(frame: .zero, style: .insetGrouped)
        view.rowHeight = 60
        return view
    }()
    
    let todayButton: UIButton = {
        let view = UIButton()
        view.setTitle("오늘", for: .normal)
        view.backgroundColor = .orange
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        headerView.addSubview(selectCollectionView)
        homeTableView.calendarView.addSubview(todayButton)
//        imageView.addSubview(imageButton)
        [headerView, homeTableView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }

        homeTableView.snp.makeConstraints { make in
            make.bottom.trailing.leading.equalTo(self.safeAreaLayoutGuide)
            make.top.equalTo(headerView.snp.bottom)
        }
        
        selectCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.trailing.bottom.equalTo(headerView)
            make.width.equalTo(self)
        }
        
        todayButton.snp.makeConstraints { make in
            make.centerY.equalTo(homeTableView.calendar.calendarHeaderView.snp.centerY)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(20)
            make.width.equalTo(50)
        }
    }
    
    static func selectCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = 55
        let spacing: CGFloat = 8
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width, height: 44)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        return layout
    }
}
