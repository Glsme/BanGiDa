//
//  AnalyticsRepository.swift
//  BanGiDa
//
//  Created by Claude on 4/16/26.
//

import Foundation

public protocol AnalyticsRepository {
    func logEvent(_ name: String, parameters: [String: Any]?)
    func recordError(_ error: Error, userInfo: [String: Any]?)
}
