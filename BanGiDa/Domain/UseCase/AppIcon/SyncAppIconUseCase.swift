//
//  SyncAppIconUseCase.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/08/10.
//

import Foundation

protocol SyncAppIconUseCase {
    /// 원격 설정에 맞춰 앱 아이콘을 동기화한다. 콜드스타트마다 한 번만 호출한다.
    @MainActor
    func execute() async throws
}

final class SyncAppIconUseCaseImpl: SyncAppIconUseCase {
    private let appIconRepository: AppIconRepository
    private let appIconRemoteRepository: AppIconRemoteRepository

    init(
        appIconRepository: AppIconRepository,
        appIconRemoteRepository: AppIconRemoteRepository
    ) {
        self.appIconRepository = appIconRepository
        self.appIconRemoteRepository = appIconRemoteRepository
    }

    @MainActor
    func execute() async throws {
        guard appIconRepository.supportsAlternateIcons else { return }

        let targetIcon = await appIconRemoteRepository.activateFetchedIcon()

        // 같은 아이콘에 다시 적용하면 화면만 바뀌지 않고 시스템 알림만 노출되므로 건너뛴다.
        if targetIcon != appIconRepository.currentIcon {
            try await appIconRepository.apply(targetIcon)
        }

        // 새로 받은 값은 다음 콜드스타트에 반영된다.
        await appIconRemoteRepository.fetchForNextLaunch()
    }
}
