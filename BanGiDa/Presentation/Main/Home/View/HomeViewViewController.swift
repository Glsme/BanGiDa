//
//  HomeViewViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import FSCalendar
import FirebaseAnalytics

class HomeViewViewController: BaseViewController, UIGestureRecognizerDelegate {
    
    let mainView = HomeView()
    let viewModel = HomeViewModel()
    
    lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: mainView.homeTableView.calendar, action: #selector(mainView.homeTableView.calendar.handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.currentDate.value = mainView.homeTableView.calendar.today ?? Date()
        bind()
        todayButtonClicked()
        sendFireBaseAnalytics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        setData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        checkWalkThrough()
    }
    
    func sendFireBaseAnalytics() {
//        Analytics.logEvent("homeView Open", parameters: nil)
        
        Analytics.logEvent("AppFirstOpen", parameters: [ 
          "name": "BangiDaLog",
          "full_text": "App Run First Time",
        ])
    }
    
    func checkWalkThrough() {
        if UserDefaults.standard.bool(forKey: "first") {
            viewModel.filterNotification()
        } else {
            let walkThroughVC = WalkThroughViewController()
            self.transViewController(ViewController: walkThroughVC, type: .presentFullscreen)
        }
    }
    
    override func configureUI() {
        //tableView
        mainView.homeTableView.delegate = self
        mainView.homeTableView.dataSource = self
        
        //Calendar
        mainView.homeTableView.calendar.delegate = self
        mainView.homeTableView.calendar.dataSource = self
        
        //CollectionView
        mainView.selectCollectionView.delegate = self
        mainView.selectCollectionView.dataSource = self
        
        mainView.todayButton.addTarget(self, action: #selector(todayButtonClicked), for: .touchUpInside)
        mainView.dateSelectButton.addTarget(self, action: #selector(dateSelectButtonClcicked), for: .touchUpInside)
        
        view.addGestureRecognizer(self.scopeGesture)
        mainView.homeTableView.panGestureRecognizer.require(toFail: scopeGesture)
        //        mainView.homeTableView.calendar.scope = .month
        
        mainView.homeTableView.calendar.accessibilityIdentifier = "calendar"
    }
    
    override func setData() {
        viewModel.tasks = UserDiaryRepository.shared.fetchDate(date: viewModel.currentDate.value)
        viewModel.inputDataIntoArrayToDate(date: viewModel.currentDate.value)
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainView.homeTableView.calendar.reloadData()
            self.mainView.homeTableView.reloadData()
        }
    }
    
    func bind() {
        viewModel.currentDate.bind { [weak self] date in
            guard let self = self else { return }
            self.viewModel.tasks = UserDiaryRepository.shared.fetchDate(date: date)
            self.viewModel.inputDataIntoArrayToDate(date: date)
            self.mainView.homeTableView.reloadData()
        }
    }
    
    @objc func todayButtonClicked() {
        mainView.homeTableView.calendar.setCurrentPage(Date(), animated: true)
        mainView.homeTableView.calendar.select(Date(), scrollToDate: true)
        calendar(mainView.homeTableView.calendar, didSelect: mainView.homeTableView.calendar.today ?? Date(), at: .current)
    }
    
    @objc func dateSelectButtonClcicked() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = Locale(identifier: "ko_KR")
        datePicker.addTarget(self, action: #selector(selectDate(_ :)), for: .touchUpInside)
        
        let calendar = Calendar(identifier: .gregorian)
        let currentDate = Date()
        var components = DateComponents()
        components.calendar = calendar
        
        components.year = 60
        let maxDate = calendar.date(byAdding: components, to: currentDate)!
        
        components.year = -50
        let minDate = calendar.date(byAdding: components, to: currentDate)!
        
        datePicker.minimumDate = minDate
        datePicker.maximumDate = maxDate
        
        let ok = UIAlertAction(title: "선택 완료", style: .cancel) { [weak self] action in
            guard let self = self else { return }
            
            self.viewModel.currentDateString.value = self.dateFormatter.string(from: datePicker.date)
            self.viewModel.currentDate.value = self.dateFormatter.date(from: self.viewModel.currentDateString.value) ?? Date()
                        
            self.calendar(self.mainView.homeTableView.calendar, didSelect: self.viewModel.currentDate.value, at: .current)
            
            self.mainView.homeTableView.calendar.setCurrentPage(self.viewModel.currentDate.value, animated: true)
            self.mainView.homeTableView.calendar.select(self.viewModel.currentDate.value, scrollToDate: true)
        }
        
        alert.addAction(ok)
        
        let vc = UIViewController()
        vc.view = datePicker
        
        alert.setValue(vc, forKey: "contentViewController")
        
        present(alert, animated: true)
    }
    
    @objc func selectDate(_ datePicker: UIDatePicker) {
        //        date = datePicker.date
    }
    
    func pushNavigationController(index: Int) {
        if index == 1 {
            if viewModel.alarmPrivacy.value {
                let vc = AlarmViewController()
                vc.navigationItem.title = viewModel.selectButtonList[index].title
                transViewController(ViewController: vc, type: .push)
            } else {
                showAlert(message: "알람 사용을 위해 알람 권한을 허용해주세요.")
            }
        } else {
            let vc = WriteViewController()
            vc.navigationItem.title = viewModel.selectButtonList[index].title
            vc.viewModel.currentIndex.value = index
            vc.memoView.dateTextField.text = dateFormatter.string(from: viewModel.currentDate.value)
            transViewController(ViewController: vc, type: .push)
        }
    }
}

extension HomeViewViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.setHeaderHeight(section: section)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewModel.setTableViewHeaderView(section: section)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checkNumberOfRowsInsection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return viewModel.cellForRowAt(tableView: tableView, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.enterEditMemo(ViewController: self, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil, alarmTitle: nil)
            let category = Category(rawValue: indexPath.section)
            
            switch category {
            case .memo:
                task = self.viewModel.memoTaskList[indexPath.row]
            case .alarm:
                self.viewModel.removeNotification(title: self.viewModel.alarmTaskList[indexPath.row].alarmTitle ?? "",
                                                  body: self.viewModel.alarmTaskList[indexPath.row].content,
                                                  date: self.viewModel.alarmTaskList[indexPath.row].date,
                                                  index: indexPath.row)
                task = self.viewModel.alarmTaskList[indexPath.row]
            case .growth:
                task = self.viewModel.growthTaskList[indexPath.row]
            case .shower:
                task = self.viewModel.showerTaskList[indexPath.row]
            case .hospital:
                task = self.viewModel.hospitalTaskList[indexPath.row]
            case .abnormal:
                task = self.viewModel.abnormalTaskList[indexPath.row]
            default:
                break
            }
            
            UserDiaryRepository.shared.delete(task)
            self.viewModel.fetchData()
            
            self.mainView.homeTableView.calendar.reloadData()
            self.mainView.homeTableView.reloadData()
        }
        
        let image = UIImage(systemName: "trash.fill")
        delete.image = image
        delete.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension HomeViewViewController: FSCalendarDelegate, FSCalendarDataSource {
    func minimumDate(for calendar: FSCalendar) -> Date {
        return dateFormatterForCalendar.date(from: "1970.01.01")!
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        return dateFormatterForCalendar.date(from: "2099.12.31")!
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let shouldBegin = mainView.homeTableView.contentOffset.y <= -mainView.homeTableView.contentInset.top
        if shouldBegin {
            let velocity = self.scopeGesture.velocity(in: self.view)
            switch mainView.homeTableView.calendar.scope {
            case .month:
                return velocity.y < 0
            case .week:
                return velocity.y > 0
            @unknown default:
                fatalError()
            }
        }
        return shouldBegin
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        if UserDiaryRepository.shared.fetchDate(date: date).count == 0 {
            return 0
        } else {
            return 1
        }
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }
        
        self.view.layoutIfNeeded()
        mainView.homeTableView.reloadData()
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.currentDate.value = date
        viewModel.tasks = UserDiaryRepository.shared.fetchDate(date: viewModel.currentDate.value)
        viewModel.inputDataIntoArrayToDate(date: viewModel.currentDate.value)
        
        mainView.homeTableView.reloadData()
    }
}

extension HomeViewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectButtonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return viewModel.cellForItemAt(collectionView: collectionView, indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        pushNavigationController(index: indexPath.item)
    }
}
