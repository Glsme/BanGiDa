//
//  HomeView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

import SnapKit

final class HomeView: BaseView {
    
    let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let selectCollectionView: SelectButtonCollectionView = {
        let view = SelectButtonCollectionView(frame: .zero, collectionViewLayout: selectCollectionViewLayout())
        view.register(SelectButtonCollectionViewCell.self, forCellWithReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier)
        return view
    }()
    
    let homeTableView: HomeTableView = {
        let view = HomeTableView(frame: .zero, style: .insetGrouped)
        view.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reuseIdentifier)
        view.register(AlarmListTableViewCell.self, forCellReuseIdentifier: AlarmListTableViewCell.reuseIdentifier)
        view.contentInset = .zero
        view.contentInsetAdjustmentBehavior = .never
        view.rowHeight = 100
        return view
    }()
    
    let todayButton: UIButton = {
        let view = UIButton()
        view.setTitle("Today", for: .normal)
        view.titleLabel?.font = UIFont(name: "HelveticaNeue-Medium", size: 14)
        view.setTitleColor(UIColor.greenblue, for: .normal)
        return view
    }()
    
    let dateSelectButton: UIButton = {
        let view = UIButton()
        view.setImage(UIImage(systemName: "calendar"), for: .normal)
        view.tintColor = .memoDarkGray
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }
    
    override func configureUI() {
        headerView.addSubview(selectCollectionView)
        homeTableView.calendar.addSubview(todayButton)
        homeTableView.calendar.addSubview(dateSelectButton)
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
            make.width.equalTo(self).multipliedBy(0.95)
            make.centerX.equalTo(self)
        }
        
        todayButton.snp.makeConstraints { make in
            make.centerY.equalTo(homeTableView.calendar.calendarHeaderView.snp.centerY).multipliedBy(1.1)
            make.trailing.equalTo(self.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(20)
            make.width.equalTo(50)
        }
        
        dateSelectButton.snp.makeConstraints { make in
            make.centerY.equalTo(homeTableView.calendar.calendarHeaderView.snp.centerY).multipliedBy(1.2)
            make.leading.equalTo(self.safeAreaLayoutGuide).offset(20)
            make.height.width.equalTo(50)
        }
    }
    
    static func selectCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let width = (UIScreen.main.bounds.width * 0.95) - (spacing * 5)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width / 6, height: width / 6)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        return layout
    }
}
