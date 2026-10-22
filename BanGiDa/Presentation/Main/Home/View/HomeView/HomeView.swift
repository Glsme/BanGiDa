//
//  HomeView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

import SnapKit

final class HomeView: BaseView {

    private static let addButtonSize: CGFloat = 56
    private static let addButtonMargin: CGFloat = 16

    let homeTableView: HomeTableView = {
        let view = HomeTableView(frame: .zero, style: .insetGrouped)
        view.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reuseIdentifier)
        view.register(AlarmListTableViewCell.self, forCellReuseIdentifier: AlarmListTableViewCell.reuseIdentifier)
        // 마지막 기록이 + 버튼에 가려지지 않도록 버튼 높이만큼 아래 여백을 둔다.
        let bottomInset = HomeView.addButtonSize + HomeView.addButtonMargin * 2
        view.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: bottomInset, right: 0)
        view.verticalScrollIndicatorInsets.bottom = bottomInset
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

    // 카테고리별 기록 작성 진입점. iPhone Duo에서 측면 세로 바와 겹치지 않도록
    // 상단 가로 행 대신 safe area 안 오른쪽 아래에 두고, 카테고리는 시스템 메뉴로 띄운다.
    let addButton: UIButton = {
        var configuration: UIButton.Configuration
        if #available(iOS 26.0, *) {
            configuration = .prominentGlass()
        } else {
            configuration = .filled()
            configuration.cornerStyle = .capsule
        }
        configuration.image = UIImage(
            systemName: "plus",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold)
        )
        configuration.baseBackgroundColor = .greenblue
        configuration.baseForegroundColor = .white

        let view = UIButton(configuration: configuration)
        view.tintColor = .greenblue
        view.showsMenuAsPrimaryAction = true
        view.preferredMenuElementOrder = .fixed
        view.accessibilityLabel = "새 기록 작성"
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    override func layoutSubviews() {
        super.layoutSubviews()

        homeTableView.setInitialCalendarHeightIfNeeded(AdaptiveLayout.calendarHeight(containerHeight: bounds.height))
    }

    override func configureUI() {
        homeTableView.calendar.addSubview(todayButton)
        homeTableView.calendar.addSubview(dateSelectButton)
//        imageView.addSubview(imageButton)
        [homeTableView, addButton].forEach {
            self.addSubview($0)
        }
    }

    override func setConstraints() {
        homeTableView.snp.makeConstraints { make in
            make.edges.equalTo(self.safeAreaLayoutGuide)
        }

        addButton.snp.makeConstraints { make in
            make.trailing.bottom.equalTo(self.safeAreaLayoutGuide).inset(Self.addButtonMargin)
            make.width.height.equalTo(Self.addButtonSize)
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
}
