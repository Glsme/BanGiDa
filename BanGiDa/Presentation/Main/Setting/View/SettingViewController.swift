//
//  SettingViewController.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import MessageUI
import PhotosUI
import StoreKit
import SwiftUI
import UIKit

import AcknowList
import CropViewController
import DesignSystem

final class SettingViewController: BaseViewController {
    
    private let mainView = SettingView()
    private let viewModel = SettingViewModel()
    @Injected private var createBackupUseCase: CreateBackupUseCase
    @Injected private var restoreBackupUseCase: RestoreBackupUseCase
    @Injected private var saveImageUseCase: SaveImageUseCase
    @Injected private var loadImageUseCase: LoadImageUseCase

    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    
    //MARK: - Life Cycle
    
    override func loadView() {
        self.view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let name = viewModel.getPetName()
        mainView.profileView.nameButton.setTitle(name ?? "이름을 입력해주세요", for: .normal)

        if let imageData = loadImageUseCase.execute(fileName: "UserProfile.jpg") {
            mainView.profileView.setProfileImage(UIImage(data: imageData))
        } else {
            mainView.profileView.setProfileImage(nil)
        }

        viewModel.loadCommentNotificationEnabled()
    }
    
    //MARK: - UI
    
    override func configureUI() {
        mainView.settingTableView.delegate = self
        mainView.settingTableView.dataSource = self
        
        self.navigationItem.title = "설정"
        mainView.profileView.imageButton.addTarget(self, action: #selector(imageButtonClicked), for: .touchUpInside)
        mainView.profileView.nameButton.addTarget(self, action: #selector(nameButtonClicked), for: .touchUpInside)
        viewModel.onCommentNotificationEnabledChanged = { [weak self] _ in
            self?.mainView.settingTableView.reloadData()
        }
        viewModel.onCommentNotificationUpdateFailed = { [weak self] _ in
            self?.showAlert(message: "댓글 알림 설정을 저장하지 못했어요. 다시 시도해 주세요.")
        }
    }
    
    //MARK: - Private
    
    private func backupFileButtonDidTap() {
        do {
            let backupFilePath = try createBackupUseCase.execute()
            showActivityViewController(filePath: backupFilePath)
        } catch {
            showAlert(message: "백업 파일 생성에 실패했습니다.\n\(error.localizedDescription)")
        }
    }
    
    private func restoreFileButtonDidTap() {
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
        vc.isNameChanged = { [weak self] in
            guard let self = self else { return }
            self.mainView.profileView.nameButton.setTitle(self.viewModel.getPetName() ?? "", for: .normal)
        }
        self.present(vc, animated: true)
    }
    
    private func moveToReview() {
        if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(6443524869)?ls=1&mt=8&action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        }
    }
    
    private func initalizeButtonDidTap() {
        showSelectAlert(message: "데이터 초기화 시 기존 데이터는 전부 사라집니다. \n\n데이터 초기화를 진행할까요?") { [weak self] _ in
            guard let self = self else { return }
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

    private func showBlockedUsers() {
        let viewController = UIHostingController(rootView: BlockedUsersView())
        viewController.title = "차단 목록"
        transViewController(ViewController: viewController, type: .push)
    }

    @objc private func commentNotificationSwitchChanged(_ sender: UISwitch) {
        viewModel.setCommentNotificationEnabled(sender.isOn)
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

        if indexPath.section == 1 && indexPath.row == viewModel.serviceLabel.count - 1 {
            let notificationSwitch = UISwitch()
            notificationSwitch.isOn = viewModel.isCommentNotificationEnabled
            notificationSwitch.addTarget(
                self,
                action: #selector(commentNotificationSwitchChanged),
                for: .valueChanged
            )
            cell.image.isHidden = true
            cell.accessoryView = notificationSwitch
            cell.selectionStyle = .none
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            cell.image.isHidden = true
            cell.versionLabel.text = viewModel.version
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0 where indexPath.row == 0:
            backupFileButtonDidTap()
        case 0 where indexPath.row == 1:
            restoreFileButtonDidTap()
        case 0 where indexPath.row == 2:
            initalizeButtonDidTap()
        case 1 where indexPath.row == 0:
            moveToReview()
        case 1 where indexPath.row == 1:
            sendMail()
        case 1 where indexPath.row == 2:
            showBlockedUsers()
        case 2 where indexPath.row == 0:
            openSourceLibraryButtonDidTap()
        default:
            break
        }
        mainView.settingTableView.deselectRow(at: indexPath, animated: true)
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

        do {
            try restoreBackupUseCase.execute(fileURL: selectedFileURL)
            viewModel.setNotifications()
            tabBarController?.selectedIndex = 0
        } catch {
            showAlert(message: "\(error.localizedDescription)\n복구에 실패하였습니다.\n다시 시도해 주세요.\n 계속 실패 시 관리자에게 문의해주세요.")
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
            showAlert(message: "알 수 없는 메일 결과입니다.")
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
        mainView.profileView.setProfileImage(image)

        var saveError: Error?
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            do {
                try saveImageUseCase.execute(fileName: "UserProfile.jpg", data: imageData)
            } catch {
                saveError = error
            }
        } else {
            saveError = DocumentError.saveImageError
        }

        dismiss(animated: true) { [weak self] in
            guard let self, let saveError else { return }
            print("SettingViewController profile image save failed: \(saveError)")
            self.showAlert(message: "프로필 이미지 저장에 실패했습니다.")
        }
    }
}
