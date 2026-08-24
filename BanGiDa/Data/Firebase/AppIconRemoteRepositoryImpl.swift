//
//  AppIconRemoteRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/08/10.
//

import Foundation

import FirebaseRemoteConfig
import Domain

final class AppIconRemoteRepositoryImpl: AppIconRemoteRepository {
    /// Remote Config 콘솔에 등록해야 하는 파라미터 키.
    private enum Key {
        static let appIconName = "app_icon_name"
    }

    private let remoteConfig: RemoteConfig

    init(remoteConfig: RemoteConfig = RemoteConfig.remoteConfig()) {
        self.remoteConfig = remoteConfig

        // 콘솔에 값이 없거나 한 번도 내려받지 못한 기기에서는 기본 아이콘을 쓴다.
        remoteConfig.setDefaults([Key.appIconName: AppIcon.default.rawValue as NSObject])

        #if DEBUG
        // 기본 12시간 간격이면 콘솔에서 값을 바꿔도 검증이 불가능하므로 디버그 빌드에서만 제한을 푼다.
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        #endif
    }

    func activateFetchedIcon() async -> AppIcon {
        // 활성화에 실패해도 직전에 활성화된 값이나 기본값이 남으므로 그대로 읽는다.
        _ = try? await remoteConfig.activate()

        let remoteValue = remoteConfig[Key.appIconName].stringValue
        return AppIcon(remoteValue: remoteValue)
    }

    func fetchForNextLaunch() async {
        // 네트워크가 없거나 실패하면 다음 실행에서 다시 시도하면 되므로 오류를 흡수한다.
        _ = try? await remoteConfig.fetch()
    }
}
