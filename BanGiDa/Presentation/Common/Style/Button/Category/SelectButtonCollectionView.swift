//
//  HomeSelectCollectionView.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

class SelectButtonCollectionView: UICollectionView {

    private var lastMeasuredSize: CGSize = .zero

    convenience init() {
        self.init(frame: .zero, collectionViewLayout: Self.makeLayout())
    }

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)

        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        // 셀을 배치하기 전에 현재 크기로 아이템 크기를 맞춰야 이전 크기로 한 번 그려지지 않는다.
        updateItemMetricsIfNeeded()
        super.layoutSubviews()
    }

    static func makeLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = AdaptiveLayout.categoryMinimumSpacing
        layout.minimumInteritemSpacing = 0

        return layout
    }

    // 접기·펼치기로 크기가 바뀌면 버튼 크기와 간격을 컨테이너 기준으로 다시 계산한다.
    private func updateItemMetricsIfNeeded() {
        guard bounds.size != lastMeasuredSize,
              let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return }

        lastMeasuredSize = bounds.size
        let metrics = AdaptiveLayout.categoryItemMetrics(containerSize: bounds.size)
        guard metrics.itemSide > 0 else { return }

        layout.itemSize = CGSize(width: metrics.itemSide, height: metrics.itemSide)
        layout.minimumLineSpacing = metrics.spacing
    }
}
