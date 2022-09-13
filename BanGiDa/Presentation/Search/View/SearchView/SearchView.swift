//
//  SearchView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/13.
//

import UIKit
import SnapKit

class SearchView: BaseView {
    
    let headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    let selectCollectionView: SelectButtonCollectionView = {
        let view = SelectButtonCollectionView(frame: .zero, collectionViewLayout: selectCollectionViewLayout())
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func configureUI() {
        headerView.addSubview(selectCollectionView)
        [headerView].forEach {
            self.addSubview($0)
        }
    }
    
    override func setConstraints() {
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self.safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
        
        selectCollectionView.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide)
            make.trailing.bottom.equalTo(headerView)
            make.width.equalTo(self).multipliedBy(0.95)
            make.centerX.equalTo(self)
        }
    }
    
    static func selectCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 10
        let width = (UIScreen.main.bounds.width * 0.95) - (spacing * 5)
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: width / 6, height: width / 6)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = 0
//        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        
        return layout
    }
}
