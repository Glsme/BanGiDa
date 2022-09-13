//
//  SettingViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

class SettingViewController: BaseViewController {

    let settingView = SettingView()
    
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .lightGray
        
        return cell
    }
    
    
}
