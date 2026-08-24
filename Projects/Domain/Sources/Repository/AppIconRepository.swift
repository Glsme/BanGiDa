//
//  AppIconRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/08/10.
//

import Foundation

/// 홈 화면 아이콘의 현재 상태를 읽고 교체한다.
/// 시스템 아이콘 API는 메인 스레드에서만 다룰 수 있으므로 프로토콜 단계에서 격리를 강제한다.
@MainActor
package protocol AppIconRepository {
    /// 기기가 대체 아이콘을 지원하는지 여부.
    var supportsAlternateIcons: Bool { get }

    /// 현재 적용된 아이콘.
    var currentIcon: AppIcon { get }

    /// 아이콘을 교체한다. 호출 시 시스템 알림이 노출되므로 실제로 바뀔 때만 호출해야 한다.
    func apply(_ icon: AppIcon) async throws
}
