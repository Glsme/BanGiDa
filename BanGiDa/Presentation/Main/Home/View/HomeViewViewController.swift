//
//  HomeViewViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import Combine

import FSCalendar
import FirebaseAnalytics

final class HomeViewViewController: BaseViewController, UIGestureRecognizerDelegate {

    let mainView = HomeView()
    let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()

    lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: mainView.homeTableView.calendar, action: #selector(mainView.homeTableView.calendar.handleScopeGesture))
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

        viewModel.currentDate = mainView.homeTableView.calendar.today ?? Date()
        bind()
        todayButtonClicked()
        sendFireBaseAnalytics("AppOpen")
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

        mainView.homeTableView.calendar.accessibilityIdentifier = "calendar"
    }

    func setData() {
        viewModel.inputDataIntoArrayToDate(date: viewModel.currentDate)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.mainView.homeTableView.calendar.reloadData()
            self.mainView.homeTableView.reloadData()
        }
    }

    func bind() {
        viewModel.$currentDate
            .sink { [weak self] date in
                guard let self = self else { return }
                self.viewModel.inputDataIntoArrayToDate(date: date)
                self.mainView.homeTableView.reloadData()
            }
            .store(in: &cancellables)

        viewModel.$alarmPrivacy
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.mainView.selectCollectionView.reloadData()
            }
            .store(in: &cancellables)
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

            self.viewModel.currentDateString = self.dateFormatter.string(from: datePicker.date)
            self.viewModel.currentDate = self.dateFormatter.date(from: self.viewModel.currentDateString) ?? Date()

            self.calendar(self.mainView.homeTableView.calendar, didSelect: self.viewModel.currentDate, at: .current)

            self.mainView.homeTableView.calendar.setCurrentPage(self.viewModel.currentDate, animated: true)
            self.mainView.homeTableView.calendar.select(self.viewModel.currentDate, scrollToDate: true)
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

    //MARK: - Private

    private func sendFireBaseAnalytics(_ name: String, parameters: [String: Any]? = nil) {
        Analytics.logEvent(name, parameters: parameters)
    }

    private func checkWalkThrough() {
        if viewModel.isFirstLaunchCompleted() {
            viewModel.filterNotification()
        } else {
            let walkThroughVC = WalkThroughViewController()
            self.transViewController(ViewController: walkThroughVC, type: .presentFullscreen)

            sendFireBaseAnalytics(
                "AppFirstOpen",
                parameters: [
                    "name": "BangiDaLog",
                    "full_text": "App Run First Time",
                ]
            )
        }
    }
}

extension HomeViewViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.setHeaderHeight(section: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let category = Category(rawValue: section) else { return nil }

        let headerView = MemoHeaderView()
        headerView.headerLabel.text = category.title
        headerView.circle.backgroundColor = category.color

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        .leastNonzeroMagnitude
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return Category.allCases.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checkNumberOfRowsInsection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let category = Category(rawValue: indexPath.section)
        let entries = viewModel.taskListFor(category: category ?? .memo)
        guard indexPath.row < entries.count else { return UITableViewCell() }
        let entry = entries[indexPath.row]

        if category == .alarm {
            guard let alarmCell = tableView.dequeueReusableCell(withIdentifier: AlarmListTableViewCell.reuseIdentifier, for: indexPath) as? AlarmListTableViewCell else { return UITableViewCell() }
            let dateText = viewModel.dateAndTimeFormatter.string(from: entry.registeredDate)
            alarmCell.configureCell(date: dateText, content: entry.alarmTitle ?? "알람", alarmBackgroundColor: .memoBackgroundColor)
            return alarmCell
        } else {
            guard let memoCell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
            let dateText = viewModel.dateAndTimeFormatter.string(from: entry.registeredDate)
            let image = viewModel.loadImageData(id: entry.id).flatMap(UIImage.init(data:)) ?? UIImage(named: "BasicDog") ?? UIImage()
            memoCell.configureCell(image: image, date: dateText, content: entry.content, memoBackgroundColor: .memoBackgroundColor)
            return memoCell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let category = Category(rawValue: indexPath.section) else { return }
        let entries = viewModel.taskListFor(category: category)
        guard indexPath.row < entries.count else { return }
        let entry = entries[indexPath.row]

        if category == .alarm {
            let alarmVC = AlarmViewController()
            alarmVC.navigationItem.title = category.title
            alarmVC.alarmView.dateTextField.text = viewModel.dateAndTimeFormatter.string(from: entry.date)
            alarmVC.alarmView.memoTextView.text = entry.content
            alarmVC.alarmView.titleTextField.text = entry.alarmTitle
            alarmVC.viewModel.editingEntryID = entry.id
            transViewController(ViewController: alarmVC, type: .push)
        } else {
            let writeVC = WriteViewController()
            writeVC.memoView.textView.text = entry.content
            writeVC.memoView.dateTextField.text = viewModel.dateFormatter.string(from: entry.date)
            writeVC.memoView.imageView.image = viewModel.loadImageData(id: entry.id).flatMap(UIImage.init(data:))
            writeVC.viewModel.editingEntryID = entry.id
            writeVC.viewModel.currentIndex.value = indexPath.section

            if writeVC.memoView.imageView.image == UIImage(named: "BasicDog") || writeVC.memoView.imageView.image == nil {
                writeVC.memoView.imageButton.setTitle("이미지 추가", for: .normal)
            } else {
                writeVC.memoView.imageButton.setTitle("이미지 편집", for: .normal)
            }

            transViewController(ViewController: writeVC, type: .push)
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completionHandler in
            guard let self = self else { return }
            guard let category = Category(rawValue: indexPath.section) else { return }
            let entries = self.viewModel.taskListFor(category: category)
            guard indexPath.row < entries.count else { return }
            let entry = entries[indexPath.row]

            if category == .alarm {
                self.viewModel.removeNotification(identifier: entry.id)
            }

            self.viewModel.deleteDiary(entry)
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
        return viewModel.fetchEventCount(date: date) == 0 ? 0 : 1
    }

    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.snp.updateConstraints { make in
            make.height.equalTo(bounds.height)
        }

        self.view.layoutIfNeeded()
        mainView.homeTableView.reloadData()
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        viewModel.currentDate = date
        viewModel.inputDataIntoArrayToDate(date: viewModel.currentDate)

        mainView.homeTableView.reloadData()
    }
}

extension HomeViewViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? SelectButtonCollectionViewCell
        else { return UICollectionViewCell() }

        guard let category = Category(rawValue: indexPath.item) else { return cell }

        cell.configureCell(bgColor: category.color, image: category.image)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let category = Category(rawValue: indexPath.item) else { return }

        switch category {
        case .memo, .growth, .shower, .hospital, .abnormal:
            let vc = WriteViewController()
            push(vc, category: category)
        case .alarm:
            if viewModel.alarmPrivacy {
                let vc = AlarmViewController()
                vc.navigationItem.title = category.title
                transViewController(ViewController: vc, type: .push)
            } else {
                showAlert(message: "알람 사용을 위해 알람 권한을 허용해주세요.")
            }
        }
    }

    //MARK: - Private

    private func push(_ viewController: WriteViewController, category: Category) {
        viewController.navigationItem.title = title
        viewController.viewModel.currentIndex.value = category.rawValue
        viewController.memoView.dateTextField.text = dateFormatter.string(from: viewModel.currentDate)
        viewController.category = category
        transViewController(ViewController: viewController, type: .push)
    }
}
