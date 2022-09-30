//
//  HomeViewViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import FSCalendar

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
        
        print("HomeView",#function)
        print("Realm is located at:", UserDiaryRepository.shared.localRealm.configuration.fileURL!)
        bind()
        todayButtonClicked()
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
    
    func checkWalkThrough() {
        if UserDefaults.standard.bool(forKey: "first") {
            viewModel.filterNotification()
        } else {
            let walkThroughVC = WalkThroughViewController()
            self.transViewController(ViewController: walkThroughVC, type: .presentFullscreen)
        }
    }
    
    override func configureUI() {
        //        self.navigationController?.navigationBar.isHidden = true
        mainView.homeTableView.delegate = self
        mainView.homeTableView.dataSource = self
        mainView.homeTableView.register(MemoListTableViewCell.self, forCellReuseIdentifier: MemoListTableViewCell.reuseIdentifier)
        mainView.homeTableView.register(AlarmListTableViewCell.self, forCellReuseIdentifier: AlarmListTableViewCell.reuseIdentifier)
        
        mainView.homeTableView.calendar.delegate = self
        mainView.homeTableView.calendar.dataSource = self
        
        mainView.selectCollectionView.delegate = self
        mainView.selectCollectionView.dataSource = self
        mainView.selectCollectionView.register(SelectButtonCollectionViewCell.self, forCellWithReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier)
        
        mainView.todayButton.addTarget(self, action: #selector(todayButtonClicked), for: .touchUpInside)
        mainView.dateSelectButton.addTarget(self, action: #selector(dateSelectButtonClcicked), for: .touchUpInside)
        
        view.addGestureRecognizer(self.scopeGesture)
        mainView.homeTableView.panGestureRecognizer.require(toFail: scopeGesture)
        //        mainView.homeTableView.calendar.scope = .month
        
        mainView.homeTableView.calendar.accessibilityIdentifier = "calendar"
    }
    
    override func setData() {
        viewModel.currentDate.value = mainView.homeTableView.calendar.today ?? Date()
        viewModel.tasks = UserDiaryRepository.shared.fetchDate(date: viewModel.currentDate.value)
        viewModel.inputDataIntoArrayToDate(date: viewModel.currentDate.value)
        
        //        print(viewModel.memoTaskList.count, viewModel.alarmTaskList.count, viewModel.growthTaskList.count, viewModel.showerTaskList.count, viewModel.hospitalTaskList.count, viewModel.abnormalTaskList.count, "!!!!!!!!!!!")
        
        
        
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
        print(#function)
        
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
        
        let ok = UIAlertAction(title: "선택 완료", style: .cancel) { action in
            
            self.viewModel.currentDateString.value = self.dateFormatter.string(from: datePicker.date)
            self.viewModel.currentDate.value = self.dateFormatter.date(from: self.viewModel.currentDateString.value) ?? Date()
            
            print("\(self.viewModel.currentDate.value) ====== \(datePicker.date)" , "@@@@@")
            
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
        var dateText = ""
        var contentText = ""
        var alarmTitle = ""
        var image = UIImage()
        
        viewModel.inputDataInToCell(indexPath: indexPath) { selectedDateText, selectedContentText, selectedAlarmTitle, selectedImage in
            dateText = selectedDateText
            contentText = selectedContentText
            alarmTitle = selectedAlarmTitle
            image = selectedImage
        }
        
        if indexPath.section == 1 {
            guard let alarmCell = tableView.dequeueReusableCell(withIdentifier: AlarmListTableViewCell.reuseIdentifier, for: indexPath) as? AlarmListTableViewCell else { return UITableViewCell() }
            
            alarmCell.dateLabel.text = dateText
            alarmCell.contentLabel.text = alarmTitle
            //                alarmCell.memoImageView.backgroundColor = .memoBackgroundColor
            //                alarmCell.memoImageView.image = nil
            alarmCell.backgroundColor = .memoBackgroundColor
            
            return alarmCell
        } else {
            guard let memoCell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
            
            memoCell.dateLabel.text = dateText
            memoCell.contentLabel.text = contentText
            memoCell.memoImageView.image = image
            memoCell.backgroundColor = .memoBackgroundColor
            
            return memoCell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.enterEditMemo(ViewController: self, indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) { action, view, completionHandler in
            var task = Diary(type: nil, date: Date(), regDate: Date(), animalName: "", content: "", photo: nil, alarmTitle: nil)
            
            switch indexPath.section {
            case 0:
                task = self.viewModel.memoTaskList[indexPath.row]
            case 1:
                self.viewModel.removeNotification(title: self.viewModel.alarmTaskList[indexPath.row].alarmTitle ?? "", body: self.viewModel.alarmTaskList[indexPath.row].content, date: self.viewModel.alarmTaskList[indexPath.row].date, index: indexPath.row)
                task = self.viewModel.alarmTaskList[indexPath.row]
            case 2:
                task = self.viewModel.growthTaskList[indexPath.row]
            case 3:
                task = self.viewModel.showerTaskList[indexPath.row]
            case 4:
                task = self.viewModel.hospitalTaskList[indexPath.row]
            case 5:
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
        //        print("날짜가 선택되었습니다.")
        
        viewModel.currentDate.value = date
        //        let dateTest = Date()
        //        print("Date: \(date) :: \(dateTest)")
        viewModel.tasks = UserDiaryRepository.shared.fetchDate(date: viewModel.currentDate.value)
        viewModel.inputDataIntoArrayToDate(date: viewModel.currentDate.value)
        
        //        print(viewModel.memoTaskList.count, viewModel.alarmTaskList.count, viewModel.growthTaskList.count, viewModel.showerTaskList.count, viewModel.hospitalTaskList.count, viewModel.abnormalTaskList.count)
        
        mainView.homeTableView.reloadData()
    }
}

extension HomeViewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectButtonList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier, for: indexPath) as? SelectButtonCollectionViewCell else { return UICollectionViewCell() }
        
        cell.backgroundColor = viewModel.selectButtonList[indexPath.row].color
        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.imageView.image = viewModel.selectButtonList[indexPath.item].image
        cell.tintColor = .white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(#function, indexPath.item)
        pushNavigationController(index: indexPath.item)
    }
}
