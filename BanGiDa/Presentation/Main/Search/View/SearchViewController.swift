//
//  SearchViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import Combine
import UIKit

final class SearchViewController: BaseViewController {

    let searchView = SearchView()
    let viewModel = SearchViewModel()
    var cancelBag = Set<AnyCancellable>()

    override func loadView() {
        self.view = searchView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        bind()
        viewModel.inputDataIntoArray()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.isHidden = true

        if !viewModel.isFiltering {
            viewModel.isFiltering = true
            viewModel.currentIndex.value = 0
            collectionView(searchView.selectCollectionView, didSelectItemAt: IndexPath(item: 0, section: 0))
            searchView.selectCollectionView.reloadData()
        }

        searchView.filterTableView.reloadData()
    }

    override func configureUI() {
        searchView.selectCollectionView.delegate = self
        searchView.selectCollectionView.dataSource = self

        searchView.filterTableView.delegate = self
        searchView.filterTableView.dataSource = self
    }

    private func bind() {
        viewModel.currentIndex.sink { [weak self] _ in
            guard let self = self else { return }
            self.searchView.filterTableView.reloadData()
        }
        .store(in: &cancelBag)
    }
}

extension SearchViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Category.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item == 0 {
            collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .init())
        }

        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: SelectButtonCollectionViewCell.reuseIdentifier,
            for: indexPath
        ) as? SelectButtonCollectionViewCell
        else { return UICollectionViewCell() }

        guard let category = Category(rawValue: indexPath.item) else { return cell }

        cell.backgroundColor = .lightGray

        let backgroundView = UIView()
        backgroundView.backgroundColor = category.color
        cell.selectedBackgroundView = backgroundView

        cell.clipsToBounds = true
        cell.layer.cornerRadius = cell.frame.height / 2
        cell.imageView.image = UIImage(systemName: category.image) ?? UIImage()
        cell.tintColor = .white

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.item)
        viewModel.isFiltering = true
        viewModel.currentIndex.value = indexPath.item
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let category = Category(rawValue: viewModel.currentIndex.value ?? 0) else { return nil }

        let headerView = MemoHeaderView()
        headerView.headerLabel.text = category.title
        headerView.circle.backgroundColor = category.color

        return headerView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.currentIndex.value == nil ? 0 : 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.checkNumberOfRowsInsection(section: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var dateText = ""
        var contentText = ""
        var alarmTitle = ""
        var image = UIImage()

        inputDataInToCell(indexPath: indexPath) { selectedDateText, selectedContentText, selectedAlarmTitle, selectedImage in
            dateText = selectedDateText
            contentText = selectedContentText
            alarmTitle = selectedAlarmTitle
            image = selectedImage
        }

        if let index = viewModel.currentIndex.value, Category(rawValue: index) == .alarm {
            guard let alarmCell = tableView.dequeueReusableCell(withIdentifier: AlarmListTableViewCell.reuseIdentifier, for: indexPath) as? AlarmListTableViewCell else { return UITableViewCell() }
            alarmCell.configureCell(date: dateText, content: alarmTitle, alarmBackgroundColor: .memoBackgroundColor)

            return alarmCell
        } else {
            guard let memoCell = tableView.dequeueReusableCell(withIdentifier: MemoListTableViewCell.reuseIdentifier, for: indexPath) as? MemoListTableViewCell else { return UITableViewCell() }
            memoCell.configureCell(image: image, date: dateText, content: contentText, memoBackgroundColor: .memoBackgroundColor)

            return memoCell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        enterEditMemo(ViewController: self, indexPath: indexPath)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .normal, title: nil) { [weak self] action, view, completionHandler in
            guard let self = self else { return }

            if let index = self.viewModel.currentIndex.value {
                let category = Category(rawValue: index)
                let entries = self.viewModel.taskListFor(index: index)
                guard indexPath.row < entries.count else { return }
                let entry = entries[indexPath.row]

                if category == .alarm {
                    self.viewModel.removeNotification(
                        title: entry.alarmTitle ?? "",
                        body: entry.content,
                        date: entry.date,
                        index: indexPath.row,
                        repeatRule: entry.repeatRule
                    )
                }

                self.viewModel.deleteDiary(entry)
                self.viewModel.inputDataIntoArray()
                self.searchView.filterTableView.reloadData()
            }
        }

        let image = UIImage(systemName: "trash.fill")
        delete.image = image
        delete.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [delete])
    }
}

extension SearchViewController {
    private func inputDataInToCell(indexPath: IndexPath, completionHandler: @escaping (String, String, String, UIImage) -> () ) {
        guard let index = viewModel.currentIndex.value else { return }
        let entries = viewModel.taskListFor(index: index)
        guard indexPath.row < entries.count else { return }
        let entry = entries[indexPath.row]

        let dateText = viewModel.dateFormatter.string(from: entry.date)
        let contentText = entry.content
        let alarmTitle = entry.alarmTitle ?? "알람"
        var image = UIImage()

        if Category(rawValue: index) != .alarm {
            if let imageData = viewModel.loadImage(id: entry.id) {
                image = UIImage(data: imageData) ?? UIImage(named: "BasicDog")!
            } else {
                image = UIImage(named: "BasicDog")!
            }
        }

        completionHandler(dateText, contentText, alarmTitle, image)
    }

    private func enterEditMemo<T: UIViewController>(ViewController vc: T, indexPath: IndexPath) {
        guard let index = viewModel.currentIndex.value else { return }
        let entries = viewModel.taskListFor(index: index)
        guard indexPath.row < entries.count else { return }
        let entry = entries[indexPath.row]
        let category = Category(rawValue: index)

        if category == .alarm {
            let alarmVC = AlarmViewController()
            alarmVC.navigationItem.title = category?.title
            alarmVC.alarmView.dateTextField.text = viewModel.dateAndTimeFormatter.string(from: entry.date)
            alarmVC.alarmView.memoTextView.text = entry.content
            alarmVC.alarmView.titleTextField.text = entry.alarmTitle
            alarmVC.viewModel.editingEntryID = entry.id
            vc.transViewController(ViewController: alarmVC, type: .push)
            return
        }

        let writeVC = WriteViewController()
        writeVC.memoView.textView.text = entry.content
        writeVC.memoView.dateTextField.text = viewModel.dateFormatter.string(from: entry.date)

        if let imageData = viewModel.loadImage(id: entry.id) {
            writeVC.memoView.imageView.image = UIImage(data: imageData)
        }
        writeVC.viewModel.editingEntryID = entry.id

        if writeVC.memoView.imageView.image == UIImage(named: "BasicDog") || writeVC.memoView.imageView.image == nil {
            writeVC.memoView.imageButton.setTitle("이미지 추가", for: .normal)
        } else {
            writeVC.memoView.imageButton.setTitle("이미지 편집", for: .normal)
        }

        writeVC.viewModel.currentIndex.value = index

        vc.transViewController(ViewController: writeVC, type: .push)
    }
}
