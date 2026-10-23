//
//  HomeViewViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import Combine

final class HomeViewViewController: BaseViewController, UIGestureRecognizerDelegate {

    @Injected private var analyticsRepository: AnalyticsRepository
    let mainView = HomeView()
    let viewModel = HomeViewModel()
    private var cancellables = Set<AnyCancellable>()

    private var calendarModel: HomeCalendarModel {
        mainView.homeTableView.calendarModel
    }

    // 위아래로 끌어 주↔월을 바꾼다. 테이블 영역에서 끌어도 동작하도록 화면 전체에 붙인다.
    lazy var scopeGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleScopeGesture(_:)))
        panGesture.delegate = self
        panGesture.minimumNumberOfTouches = 1
        panGesture.maximumNumberOfTouches = 2
        return panGesture
    }()

    // 캘린더를 좌우로 끌어 이전·다음 주(월)로 넘긴다.
    lazy var pageGesture: UIPanGestureRecognizer = {
        [unowned self] in
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePageGesture(_:)))
        panGesture.delegate = self
        return panGesture
    }()

    override func loadView() {
        self.view = mainView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.currentDate = calendarModel.today
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
        addChild(mainView.homeTableView.calendarHostingController)
        mainView.homeTableView.calendarHostingController.didMove(toParent: self)
        configureCalendar()

        //AddButton
        mainView.addButton.menu = makeCategoryMenu()

        view.addGestureRecognizer(self.scopeGesture)
        mainView.homeTableView.calendarView.addGestureRecognizer(self.pageGesture)
        mainView.homeTableView.panGestureRecognizer.require(toFail: scopeGesture)
        mainView.homeTableView.panGestureRecognizer.require(toFail: pageGesture)

        mainView.homeTableView.calendarView.accessibilityIdentifier = "calendar"
    }

    func setData() {
        viewModel.inputDataIntoArrayToDate(date: viewModel.currentDate)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.calendarModel.reloadEvents()
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
    }

    @objc func todayButtonClicked() {
        let today = calendarModel.today
        calendarModel.select(today, scrollToDate: true)
        didSelectCalendarDate(today)
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

            self.didSelectCalendarDate(self.viewModel.currentDate)
            self.calendarModel.select(self.viewModel.currentDate, scrollToDate: true)
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
        analyticsRepository.logEvent(name, parameters: parameters)
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
            let image = viewModel.loadImageData(for: entry).flatMap(UIImage.init(data:)) ?? UIImage(named: "BasicDog") ?? UIImage()
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
            writeVC.memoView.imageView.image = viewModel.loadImageData(for: entry).flatMap(UIImage.init(data:))
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

            self.calendarModel.reloadEvents()
            self.mainView.homeTableView.reloadData()
        }

        let image = UIImage(systemName: "trash.fill")
        delete.image = image
        delete.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [delete])
    }
}

// MARK: - Calendar

extension HomeViewViewController {
    private func configureCalendar() {
        calendarModel.eventCount = { [weak self] date in
            self?.viewModel.fetchEventCount(date: date) ?? 0
        }
        calendarModel.onSelect = { [weak self] date in
            self?.didSelectCalendarDate(date)
        }
        calendarModel.onTodayTap = { [weak self] in
            self?.todayButtonClicked()
        }
        calendarModel.onDateSelectTap = { [weak self] in
            self?.dateSelectButtonClcicked()
        }
    }

    private func didSelectCalendarDate(_ date: Date) {
        viewModel.currentDate = date
        viewModel.inputDataIntoArrayToDate(date: viewModel.currentDate)

        mainView.homeTableView.reloadData()
    }

    @objc private func handleScopeGesture(_ gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            calendarModel.beginScopeTransition()
        case .changed:
            calendarModel.updateScopeTransition(translation: gesture.translation(in: view).y)
        case .ended, .cancelled, .failed:
            calendarModel.endScopeTransition(velocity: gesture.velocity(in: view).y)
        default:
            break
        }
    }

    @objc private func handlePageGesture(_ gesture: UIPanGestureRecognizer) {
        let calendarView = mainView.homeTableView.calendarView

        switch gesture.state {
        case .changed:
            calendarModel.updatePageDrag(translation: gesture.translation(in: calendarView).x)
        case .ended, .cancelled, .failed:
            calendarModel.endPageDrag(
                translation: gesture.translation(in: calendarView).x,
                velocity: gesture.velocity(in: calendarView).x,
                width: calendarView.bounds.width
            )
        default:
            break
        }
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer === pageGesture {
            let velocity = pageGesture.velocity(in: view)
            return abs(velocity.x) > abs(velocity.y)
        }

        guard gestureRecognizer === scopeGesture else { return true }

        // 테이블이 맨 위에 있을 때만, 주 달력은 아래로·월 달력은 위로 끌 때 전환한다.
        let isAtTop = mainView.homeTableView.contentOffset.y <= -mainView.homeTableView.contentInset.top
        guard isAtTop else { return false }

        let velocity = scopeGesture.velocity(in: view)
        guard abs(velocity.y) > abs(velocity.x) else { return false }

        switch calendarModel.scope {
        case .month:
            return velocity.y < 0
        case .week:
            return velocity.y > 0
        }
    }
}

extension HomeViewViewController {
    // 시스템 메뉴는 iPhone Duo의 접힘 영역·화면 가장자리를 피해 위치를 스스로 조정한다.
    private func makeCategoryMenu() -> UIMenu {
        let actions = Category.allCases.map { category in
            UIAction(
                title: category.title,
                image: UIImage(systemName: category.image)?
                    .withTintColor(category.color, renderingMode: .alwaysOriginal)
            ) { [weak self] _ in
                self?.startWriting(category)
            }
        }

        return UIMenu(children: actions)
    }

    private func startWriting(_ category: Category) {
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
