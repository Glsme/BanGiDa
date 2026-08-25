//
//  ReusableProtocol.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

package protocol ReusableProtocol {
    static var reuseIdentifier: String { get }
}

extension UITableViewCell: ReusableProtocol {
    package static var reuseIdentifier: String {
        return String(describing: self)
    }
}

extension UICollectionViewCell: ReusableProtocol {
    package static var reuseIdentifier: String {
        return String(describing: self)
    }
}
