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
    
    var zipFiles: [URL] = []
    
    let repository = UserDiaryRepository.shared
    
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
    
    func backupFileButtonClicked() {
        do {
            try repository.saveEncodedDataToDocument()
            let backupFilePath = try self.repository.documentManager.createBackupFile()
            
            showActivityViewController(filePath: backupFilePath)
            
        } catch {
            
        }
    }
    
    func showActivityViewController(filePath: URL) {
        let vc = UIActivityViewController(activityItems: [filePath], applicationActivities: [])
        self.transViewController(ViewController: vc, type: .present)
    }
    
    func fetchZipFiles() {
        do {
            zipFiles = try repository.documentManager.fetchDocumentZipFile()
        }
        catch {
//            showErrorAlert(error: error)
        }
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 1 {
                backupFileButtonClicked()
            }
        }
    }
}
