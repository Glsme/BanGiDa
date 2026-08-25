//
//  AlarmRepeat.swift
//  BanGiDa
//

import Foundation

package enum AlarmRepeat: Int, CaseIterable, Codable {
    case none = 0
    case daily
    case weekly
    case monthly
    case yearly
}
