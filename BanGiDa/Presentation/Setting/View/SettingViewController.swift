//
//  SettingViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import MessageUI

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
            fetchZipFiles()
        } catch {
            
        }
    }
    
    func restoreFileButtonClicked() {
        do {
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            self.present(documentPicker, animated: true)
        } catch {
            print("실패다~~~~~😎")
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
            print(#function, "실패여~")
        }
    }
}

extension SettingViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print(#function)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            showAlert(message: "선택하신 파일에 오류가 있습니다.")
            return
        }
        
        guard let path = repository.documentManager.documentDirectoryPath() else {
            showAlert(message: "도큐먼트 위치에 오류가 있습니다.")
            return
        }
        
        let sandboxFileURL = path.appendingPathComponent(selectedFileURL.lastPathComponent)
        
        if FileManager.default.fileExists(atPath: sandboxFileURL.path) {
            let fileZip = selectedFileURL.lastPathComponent
            let zipFileURL = path.appendingPathComponent(fileZip)
            do {
                try repository.documentManager.unzipFile(fileURL: zipFileURL, documentURL: path)
                
                do {
                    try repository.documentManager.fetchDocumentZipFile() // ????
                    try repository.restoreRealmForBackupFile()
                    try repository.documentManager.createBackupFile()
//                    showActivityViewController(filePath: backupFilePath)
                    tabBarController?.selectedIndex = 0
                } catch {
                    print("복구 실패")
                }
            } catch {
                print("압축 풀기 실패")
            }
        } else {
            do {
                try FileManager.default.copyItem(at: selectedFileURL, to: sandboxFileURL)
                let fileZip = selectedFileURL.lastPathComponent
                let zipfileURL = path.appendingPathComponent(fileZip)
                
                do {
                    try repository.documentManager.unzipFile(fileURL: zipfileURL, documentURL: path)
                    
                    do {
                        try repository.restoreRealmForBackupFile()
                        try repository.documentManager.createBackupFile()
//                        showActivityViewController(filePath: backupFilePath)
                        tabBarController?.selectedIndex = 0
                    } catch {
                        print("복구 실패")
                    }
                } catch {
                    print("압출 풀기 실패")
                }
            } catch {
                print("압축 해제 실패")
            }
        }
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        viewModel.setSectionHeaderView(section: section)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.setCellNumber(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier, for: indexPath) as? SettingTableViewCell else { return UITableViewCell() }
        
        cell.backgroundColor = .memoBackgroundColor
        cell.label.text = viewModel.setCellText(indexPath: indexPath)
//        cell.selectionStyle = .default
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                backupFileButtonClicked()
            case 1:
                restoreFileButtonClicked()
            case 2:
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 1 {
                sendMail()
            }
        }
    }
}

extension SettingViewController : MFMailComposeViewControllerDelegate {
    
    private func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            //메일 보내기
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["glasses.str.man@gmail.com"])
            mail.setSubject("반기다 문의사항 -")
            mail.mailComposeDelegate = self   //
            self.present(mail, animated: true)
            
        } else {
            
            showAlert(message: "메일 등록을 해주시거나 glasses.str.man@gmail.com으로 문의주세요.")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // mail view가 떴을때 정상적으로 보내졌다. 실패했다고 Toast 띄워줄 수 있음
        // 어떤식으로 대응 할 수 있을지 생각해보기
        switch result {
        case .cancelled:
            showAlert(message: "메일 전송을 취소했습니다.")
        case .failed:
            showAlert(message: "메일 전송을 실패했습니다.")
        case .saved: //임시저장
            showAlert(message: "메일을 임시 저장했습니다.")
        case .sent: // 보내짐
            showAlert(message: "메일이 전송되었습니다.")
        @unknown default:
            fatalError()
        }
        
        controller.dismiss(animated: true)
    }
}
