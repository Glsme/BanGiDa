//
//  HomeTableView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import Combine
import SwiftUI
import UIKit

import SnapKit

final class HomeTableView: UITableView {

    let calendarModel = HomeCalendarModel()

    private(set) lazy var calendarHostingController: UIHostingController<HomeCalendarView> = {
        let controller = UIHostingController(rootView: HomeCalendarView(model: calendarModel))
        controller.view.backgroundColor = .clear
        if #available(iOS 16.4, *) {
            controller.safeAreaRegions = []
        }
        return controller
    }()

    // SwiftUI 캘린더를 담는 테이블 헤더. 아래쪽 모서리를 둥글게 하고 그림자를 준다.
    let calendarView: UIView = {
        let view = UIView()
        view.backgroundColor = .backgroundColor
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMaxYCorner, .layerMinXMaxYCorner)

        view.layer.shadowColor = UIColor.black.cgColor // 색깔
        view.layer.masksToBounds = false
        view.layer.shadowOffset = CGSize(width: 0, height: 4) // 위치조정
        view.layer.shadowRadius = 2 // 반경
        view.layer.shadowOpacity = 0.1 // alpha값
        return view
    }()

    private var calendarHeightConstraint: Constraint?
    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)

        configureUI()
        setConstraints()
        bindCalendar()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configureUI() {
        calendarView.addSubview(calendarHostingController.view)
        self.addSubview(calendarView)
        tableHeaderView = calendarView

        backgroundColor = .backgroundColor
        separatorColor = .systemTintColor
        separatorStyle = .singleLine
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    func setConstraints() {
        calendarHostingController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        calendarView.snp.makeConstraints { make in
            calendarHeightConstraint = make.height.equalTo(0).constraint
            make.width.equalTo(self.safeAreaLayoutGuide)
            make.centerX.equalTo(self.safeAreaLayoutGuide.snp.centerX)
            make.top.equalTo(self.snp.top)
        }
    }

    // 6주짜리 월 달력 기준 높이. 컨테이너 크기가 바뀌면(iPhone Duo 접기·펴기) 다시 계산된다.
    func updateCalendarMonthHeight(_ height: CGFloat) {
        calendarModel.setMonthHeight(height)
    }

    private func bindCalendar() {
        calendarModel.heightDidChange
            .sink { [weak self] change in
                self?.updateCalendarHeight(change.height, animated: change.animated)
            }
            .store(in: &cancellables)
    }

    // 주/월 전환과 월 페이지 이동에 맞춰 헤더 높이를 바꾼다.
    private func updateCalendarHeight(_ height: CGFloat, animated: Bool) {
        let apply = { [weak self] in
            guard let self else { return }
            self.calendarHeightConstraint?.update(offset: height)
            self.calendarView.frame.size.height = height
            // 테이블 헤더 높이 변경은 tableHeaderView를 다시 대입해야 반영된다.
            self.tableHeaderView = self.calendarView
            self.layoutIfNeeded()
        }

        if animated {
            UIView.animate(
                withDuration: HomeCalendarModel.settleDuration,
                delay: 0,
                options: [.curveEaseOut, .beginFromCurrentState],
                animations: apply
            )
        } else {
            apply()
        }
    }
}
