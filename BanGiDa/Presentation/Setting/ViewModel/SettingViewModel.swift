//
//  SettingViewModel.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit

class SettingViewModel: CommonViewModel {
    
    let dataLabel = ["백업", "복구", "초기화"]
    let serviceLabel = ["리뷰 남기기", "문의하기"]
    let appInfoLabel = ["오픈소스 라이브러리", "버전 정보"]
    
    let settingTitleLabels = ["데이터", "서비스", "앱 정보"]
    
    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!
    
    var version: String? {
        guard let dictionary = Bundle.main.infoDictionary,
              let version = dictionary["CFBundleShortVersionString"] as? String,
              let _ = dictionary["CFBundleVersion"] as? String else {return nil}
        
        let versionAndBuild: String = "\(version)"
        return versionAndBuild
    }
    
    func setSectionHeaderView(section: Int) -> String {
        switch section {
        case 0:
            return "데이터"
        case 1:
            return "서비스"
        case 2:
            return "앱 정보"
        default:
            return ""
        }
    }
    
    func setCellNumber(section: Int) -> Int {
        if section == 0 {
            return dataLabel.count
        } else if section == 1 {
            return serviceLabel.count
        } else if section == 2 {
            return appInfoLabel.count
        } else {
            return 0
        }
    }
    
    func setCellText(indexPath: IndexPath) -> String {
        var text = ""
        
        if indexPath.section == 0 {
            text = dataLabel[indexPath.row]
        } else if indexPath.section == 1 {
            text = serviceLabel[indexPath.row]
        } else if indexPath.section == 2 {
            text = appInfoLabel[indexPath.row]
        }
        
        return text
    }
    
    func setNotifications() {
        UserDiaryRepository.shared.fetch()
        inputDataIntoArray()
        
        var index = 0
        
        for item in alarmTaskList {
            if item.date > Date() {
                sendNotification(title: item.animalName, body: item.content, date: item.date, index: index)
            }
            
            index += 1
        }
    }
    
    func resetData() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.first.rawValue)
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.name.rawValue)
        UserDiaryRepository.shared.deleteAll()
        removeAllNotification()
    }
    
    func configureDataSource(settingCollectionView: UICollectionView) {
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, String>(handler: { cell, indexPath, itemIdentifier in
            var content = UIListContentConfiguration.valueCell()
            
            if indexPath.section == 2, indexPath.item == 1 {
                content.secondaryAttributedText = NSAttributedString(string: self.version ?? "2.0.0", attributes: [.font: UIFont(name: "HelveticaNeue-Medium", size: 14) ?? UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.black])
            } else {
                content.secondaryAttributedText = NSAttributedString(string: "→", attributes: [.font: UIFont(name: "HelveticaNeue-Medium", size: 20) ?? UIFont.systemFont(ofSize: 16), .foregroundColor: UIColor.black])
            }
            
            content.attributedText = NSAttributedString(string: itemIdentifier, attributes: [.font: UIFont(name: "HelveticaNeue-Medium", size: 14) ?? UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.black])
            
            cell.contentConfiguration = content
            
            var background = UIBackgroundConfiguration.listPlainCell()
            background.backgroundColor = .ultraLightGray
            cell.backgroundConfiguration = background
        })
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { headerView, elementKind, indexPath in
            
            var configuration = headerView.defaultContentConfiguration()
            configuration.text = self.settingTitleLabels[indexPath.section]
            
            headerView.contentConfiguration = configuration
        }
        
        dataSource = UICollectionViewDiffableDataSource(collectionView: settingCollectionView, cellProvider: { collectionView, indexPath, itemIdentifier in
            let cell = collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: itemIdentifier)
            
            return cell
        })
        
        dataSource.supplementaryViewProvider = {
            (collectionView, elementKind, indexPath) -> UICollectionReusableView? in
            return settingCollectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0, 1, 2])
        snapshot.appendItems(dataLabel, toSection: 0)
        snapshot.appendItems(serviceLabel, toSection: 1)
        snapshot.appendItems(appInfoLabel, toSection: 2)
        
        dataSource.apply(snapshot)
    }
}
