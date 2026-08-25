//
//  MockAppIconRepositories.swift
//  BanGiDaTests
//
//  Created by Seokjune Hong on 2026/08/10.
//

import Foundation
import Domain

@testable import BanGiDa

final class MockAppIconRepository: AppIconRepository {
    var supportsAlternateIcons = true
    var currentIcon: AppIcon = .default
    var applyError: Error?

    private(set) var appliedIcons: [AppIcon] = []

    nonisolated init() {}

    func apply(_ icon: AppIcon) async throws {
        if let applyError {
            throw applyError
        }

        appliedIcons.append(icon)
        currentIcon = icon
    }
}

final class MockAppIconRemoteRepository: AppIconRemoteRepository {
    var iconToActivate: AppIcon = .default

    private(set) var activateCallCount = 0
    private(set) var fetchForNextLaunchCallCount = 0

    func activateFetchedIcon() async -> AppIcon {
        activateCallCount += 1
        return iconToActivate
    }

    func fetchForNextLaunch() async {
        fetchForNextLaunchCallCount += 1
    }
}
