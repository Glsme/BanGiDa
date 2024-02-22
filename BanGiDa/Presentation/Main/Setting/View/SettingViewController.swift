//
//  SettingViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit
import MessageUI
import AcknowList
import StoreKit
import PhotosUI
import CropViewController

final class SettingViewController: BaseViewController {
    
    let settingView = SettingView()
    let viewModel = SettingViewModel()
    
    var zipFiles: [URL] = []
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    
    let repository = UserDiaryRepository.shared
    
    //MARK: - Life Cycle
    
    override func loadView() {
        self.view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue)
        settingView.profileView.nameButton.setTitle(name ?? "이름을 입력해주세요", for: .normal)
    }
    
    //MARK: - UI
    
    override func configureUI() {
        settingView.settingTableView.delegate = self
        settingView.settingTableView.dataSource = self
        
        self.navigationItem.title = "설정"
        settingView.profileView.imageButton.addTarget(self, action: #selector(imageButtonClicked), for: .touchUpInside)
        settingView.profileView.nameButton.addTarget(self, action: #selector(nameButtonClicked), for: .touchUpInside)
    }
    
    //MARK: - Private
    
    private func backupFileButtonClicked() {
        do {
            try repository.saveEncodedDataToDocument()
            let backupFilePath = try self.repository.documentManager.createBackupFile()
            
            showActivityViewController(filePath: backupFilePath)
            fetchZipFiles()
        } catch {
            
        }
    }
    
    private func restoreFileButtonClicked() {
        showSelectAlert(message: "데이터 복구 시 기존 데이터는 삭제됩니다. \n\n복구를 진행할까요?") { [weak self] _ in
            let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [.archive], asCopy: true)
            documentPicker.delegate = self
            documentPicker.allowsMultipleSelection = false
            self?.present(documentPicker, animated: true)
        }
    }
    
    private func showActivityViewController(filePath: URL) {
        let vc = UIActivityViewController(activityItems: [filePath], applicationActivities: [])
        self.transViewController(ViewController: vc, type: .present)
    }
    
    private func fetchZipFiles() {
        do {
            zipFiles = try repository.documentManager.fetchDocumentZipFile()
        }
        catch {
            print(#function, "실패여~")
        }
    }
    
    @objc private func imageButtonClicked(_ sender: UIButton) {
        print(#function)
        
        var configuration = PHPickerConfiguration()
        configuration.filter = .any(of: [.images])
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    @objc private func nameButtonClicked(_ sender: UIButton) {
        let vc = WalkThroughViewController()
        vc.modalPresentationStyle = .automatic
        vc.walkThroughView.textLabel.text = "반려동물의 이름을 변경해주세요."
        vc.isNameChanged = {
            self.settingView.profileView.nameButton.setTitle(UserDefaults.standard.string(forKey: UserDefaultsKey.name.rawValue) ?? "", for: .normal)
        }
        self.present(vc, animated: true)
    }
    
    //MARK: - Private
    
    private func moveToReview() {
        if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(6443524869)?ls=1&mt=8&action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        }
    }
    
    private func initalizeButtonDidTap() {
        showSelectAlert(message: "데이터 초기화 시 기존 데이터는 전부 사라집니다. \n\n데이터 초기화를 진행할까요?") { _ in
            self.viewModel.resetData()
            let walkthorughVC = WalkThroughViewController()
            self.tabBarController?.selectedIndex = 0
            self.transViewController(ViewController: walkthorughVC, type: .presentFullscreen)
        }
    }
    
    private func openSourceLibraryButtonDidTap() {
        guard let url = Bundle.main.url(forResource: "Package", withExtension: "resolved"),
              let data = try? Data(contentsOf: url),
              let acknowList = try? AcknowPackageDecoder().decode(from: data) else {
            return
        }
        
        let vc = AcknowListViewController()
        vc.acknowledgements = acknowList.acknowledgements
        transViewController(ViewController: vc, type: .push)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return SettingTableHeaderView(title: viewModel.settingTitleLabels[section])
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return viewModel.dataLabel.count
        case 1: return viewModel.serviceLabel.count
        case 2: return viewModel.appInfoLabel.count
        default: return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingTableViewCell.reuseIdentifier, for: indexPath) as? SettingTableViewCell
        else { return UITableViewCell() }
        
        var title = ""
        
        switch indexPath.section {
        case 0: title = viewModel.dataLabel[indexPath.row]
        case 1: title = viewModel.serviceLabel[indexPath.row]
        case 2: title = viewModel.appInfoLabel[indexPath.row]
        default: break
        }
        
        cell.label.text = title
        
        if indexPath.section == 2 && indexPath.row == 1 {
            cell.image.isHidden = true
            cell.versionLabel.text = viewModel.version
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0 where indexPath.row == 0:
            backupFileButtonClicked()
        case 0 where indexPath.row == 1:
            restoreFileButtonClicked()
        case 0 where indexPath.row == 2:
            initalizeButtonDidTap()
        case 1 where indexPath.row == 0:
            moveToReview()
        case 1 where indexPath.row == 1:
            sendMail()
        case 2 where indexPath.row == 0:
            openSourceLibraryButtonDidTap()
        default:
            break
        }
        settingView.settingTableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UIDocumentPickerDelegate

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
//                                        showActivityViewController(filePath: backupFilePath)
                    viewModel.setNotifications()
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
                        viewModel.setNotifications()
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

//MARK: - MFMailComposeViewControllerDelegate

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

//MARK: - PHPickerViewControllerDelegate

extension SettingViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    guard let image = image as? UIImage else { return }
                    let cropVC = CropViewController(image: image)
                    cropVC.delegate = self
                    cropVC.doneButtonTitle = "완료"
                    cropVC.cancelButtonTitle = "취소"
                    self.transViewController(ViewController: cropVC, type: .present)
                }
            }
        }
    }
}

extension SettingViewController: CropViewControllerDelegate {
    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        settingView.profileView.imageView.image = image
        if image != UIImage(named: "BasicDog"),
           let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDiaryRepository.shared.documentManager.saveImageDataFromDocument(fileName: "UserProfile.jpg",
                                                                                 image: imageData)
        }
        dismiss(animated: true)
    }
}
