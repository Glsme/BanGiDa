//
//  AppIconRemoteRepository.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/08/10.
//

import Foundation

/// 원격에 설정된 앱 아이콘 값을 다룬다.
///
/// 내려받기(`fetchForNextLaunch`)와 활성화(`activateFetchedIcon`)를 분리해,
/// 이번 실행에서 받은 값은 다음 콜드스타트에 적용되도록 한다.
/// 사용 중에 아이콘이 바뀌며 시스템 알림이 튀어나오는 상황을 막기 위한 구조다.
package protocol AppIconRemoteRepository {
    /// 지난 실행에서 내려받아 둔 값을 활성화하고 그 아이콘을 돌려준다.
    /// 활성화할 값이 없거나 실패하면 기본 아이콘을 돌려준다.
    func activateFetchedIcon() async -> AppIcon

    /// 다음 실행에 쓸 값을 내려받는다. 이번 실행에는 반영하지 않는다.
    func fetchForNextLaunch() async
}
