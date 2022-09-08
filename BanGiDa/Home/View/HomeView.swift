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
        view.backgroundColor = .darkGray
        return view
    }()
    
    let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .darkGray
        view.clipsToBounds = true
        view.layer.cornerRadius = UIScreen.main.bounds.width * 0.2 / 2
        return view
    }()
    
    let selectCollectionView = HomeSelectCollectionView(frame: .zero, collectionViewLayout: selectCollectionViewLayout())
    
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
        
        [headerView, homeTableView, imageView].forEach {
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
        
        imageView.snp.makeConstraints { make in
            make.width.height.equalTo(self.safeAreaLayoutGuide.snp.width).multipliedBy(0.2)
            make.leadingMargin.equalTo(5)
            make.top.equalTo(self.safeAreaLayoutGuide).offset(10)
        }
        
        selectCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.trailing.bottom.equalTo(headerView)
            make.width.equalTo(self).multipliedBy(0.72)
        }
        
        todayButton.snp.makeConstraints { make in
            make.centerY.equalTo(homeTableView.calendarView.calendarHeaderView.snp.centerY)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-10)
            make.height.equalTo(20)
            make.width.equalTo(50)
        }
    }
    
    static func selectCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let width = 50
        let spacing: CGFloat = 8
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width, height: width)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        
        return layout
    }
}
