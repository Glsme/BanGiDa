//
//  AnalyticsRepositoryImpl.swift
//  BanGiDa
//
//  Created by Claude on 4/16/26.
//

import Foundation

import FirebaseAnalytics
import FirebaseCrashlytics

public final class AnalyticsRepositoryImpl: AnalyticsRepository {

    public init() {}

    public func logEvent(_ name: String, parameters: [String: Any]?) {
        Analytics.logEvent(name, parameters: parameters)
    }

    public func recordError(_ error: Error, userInfo: [String: Any]?) {
        Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
    }
}
