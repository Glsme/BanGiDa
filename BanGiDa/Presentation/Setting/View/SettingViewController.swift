//
//  SettingViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

class SettingViewController: BaseViewController {

    let settingView = SettingView()
    let viewModel = SettingViewModel()
    
    override func loadView() {
        self.view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func configureUI() {
        settingView.settingTableView.delegate = self
        settingView.settingTableView.dataSource = self
        settingView.settingTableView.register(SettingTableViewCell.self, forCellReuseIdentifier: SettingTableViewCell.reuseIdentifier)
        self.navigationItem.title = "설정"
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.setSectionHeaderView(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.setCellNumber(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .memoBackgroundColor
        cell.label.text = viewModel.setCellText(indexPath: indexPath)
        
        return cell
    }
    
    
}
