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

final class SettingViewController: BaseViewController {
    
    let settingView = SettingView()
    let viewModel = SettingViewModel()
    
    var zipFiles: [URL] = []
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    
    let repository = UserDiaryRepository.shared
    
    override func loadView() {
        self.view = settingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configureUI() {
        settingView.settingCollectionView.collectionViewLayout = createLayout()
        settingView.settingCollectionView.delegate = self
//        viewModel.configureDataSource(settingCollectionView: settingView.settingCollectionView)
        
        let cellRegistration = createCellRegistration()
        let headerRegistration = createHeaderRegistration()
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: settingView.settingCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
        
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            return self?.settingView.settingCollectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0, 1, 2])
        snapshot.appendItems(viewModel.dataLabel, toSection: 0)
        snapshot.appendItems(viewModel.serviceLabel, toSection: 1)
        snapshot.appendItems(viewModel.appInfoLabel, toSection: 2)
        
        dataSource.apply(snapshot)
        
        self.navigationItem.title = "??????"
    }
    
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
        showSelectAlert(message: "????????? ?????? ??? ?????? ???????????? ???????????????. \n\n????????? ????????????????") { [weak self] _ in
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
            print(#function, "?????????~")
        }
    }
}

extension SettingViewController {
    private func createLayout() -> UICollectionViewLayout {
        var config = UICollectionLayoutListConfiguration(appearance: .grouped)
        config.headerMode = .supplementary
        config.backgroundColor = UIColor.backgroundColor
        let layout = UICollectionViewCompositionalLayout.list(using: config)
        return layout
    }
    
    private func createCellRegistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, String> {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String>(handler: { [weak self] cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            
            if indexPath.section == 2, indexPath.item == 1 {
                content.secondaryAttributedText = NSAttributedString(string: self?.viewModel.version ?? "2.0.0", attributes: [.font: UIFont(name: "HelveticaNeue-Medium", size: 14) ?? UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.systemTintColor ?? UIColor.black])
            } else {
                content.secondaryAttributedText = NSAttributedString(string: "???", attributes: [.font: UIFont(name: "HelveticaNeue-Medium", size: 20) ?? UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.systemTintColor ?? UIColor.black])
            }
            
            content.attributedText = NSAttributedString(string: itemIdentifier, attributes: [.font: UIFont(name: "HelveticaNeue-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.systemTintColor ?? UIColor.black])
            
            cell.contentConfiguration = content
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .memoBackgroundColor
            cell.backgroundConfiguration = background
        })
        
        return cellRegistration
    }
    
    private func createHeaderRegistration() -> UICollectionView.SupplementaryRegistration<UICollectionViewListCell> {
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] headerView, elementKind, indexPath in
            
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = self?.viewModel.settingTitleLabels[indexPath.section]
            configuration.textProperties.font = UIFont(name: "HelveticaNeue-Medium", size: 13) ?? UIFont.systemFont(ofSize: 13)
            configuration.textProperties.color = UIColor.systemTintColor ?? UIColor.black
            headerView.contentConfiguration = configuration
        }
        
        return headerRegistration
    }
}

extension SettingViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath)
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                backupFileButtonClicked()
            case 1:
                restoreFileButtonClicked()
            case 2:
                showSelectAlert(message: "????????? ????????? ??? ?????? ???????????? ?????? ???????????????. \n\n????????? ???????????? ????????????????") { _ in
                    self.viewModel.resetData()
                    let walkthorughVC = WalkThroughViewController()
                    self.tabBarController?.selectedIndex = 0
                    self.transViewController(ViewController: walkthorughVC, type: .presentFullscreen)
                }
                break
            default:
                break
            }
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                moveToReview()
            } else if indexPath.row == 1 {
                sendMail()
            }
        } else if indexPath.section == 2 {
            if indexPath.row == 0 {
                
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
    }
    
    private func moveToReview() {
        if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(6443524869)?ls=1&mt=8&action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
            UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
        }
    }
}

extension SettingViewController: UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print(#function)
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedFileURL = urls.first else {
            showAlert(message: "???????????? ????????? ????????? ????????????.")
            return
        }
        
        guard let path = repository.documentManager.documentDirectoryPath() else {
            showAlert(message: "???????????? ????????? ????????? ????????????.")
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
                    print("?????? ??????")
                }
            } catch {
                print("?????? ?????? ??????")
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
                        print("?????? ??????")
                    }
                } catch {
                    print("?????? ?????? ??????")
                }
            } catch {
                print("?????? ?????? ??????")
            }
        }
    }
}

extension SettingViewController : MFMailComposeViewControllerDelegate {
    
    private func sendMail() {
        if MFMailComposeViewController.canSendMail() {
            //?????? ?????????
            let mail = MFMailComposeViewController()
            mail.setToRecipients(["glasses.str.man@gmail.com"])
            mail.setSubject("????????? ???????????? -")
            mail.mailComposeDelegate = self   //
            self.present(mail, animated: true)
            
        } else {
            showAlert(message: "?????? ????????? ??????????????? glasses.str.man@gmail.com?????? ???????????????.")
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        // mail view??? ????????? ??????????????? ????????????. ??????????????? Toast ????????? ??? ??????
        // ??????????????? ?????? ??? ??? ????????? ???????????????
        switch result {
        case .cancelled:
            showAlert(message: "?????? ????????? ??????????????????.")
        case .failed:
            showAlert(message: "?????? ????????? ??????????????????.")
        case .saved: //????????????
            showAlert(message: "????????? ?????? ??????????????????.")
        case .sent: // ?????????
            showAlert(message: "????????? ?????????????????????.")
        @unknown default:
            fatalError()
        }
        
        controller.dismiss(animated: true)
    }
}
