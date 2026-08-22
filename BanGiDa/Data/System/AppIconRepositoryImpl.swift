//
//  AppIconRepositoryImpl.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2026/08/10.
//

import UIKit

/// 프로토콜이 `@MainActor`라 이 타입은 메인 액터로 추론된다.
/// 다만 저장 프로퍼티가 없어 생성 자체는 격리가 필요 없으므로,
/// DIContainer가 어느 스레드에서든 인스턴스를 만들 수 있도록 init만 떼어 둔다.
final class AppIconRepositoryImpl: AppIconRepository {

    nonisolated init() {}

    var supportsAlternateIcons: Bool {
        UIApplication.shared.supportsAlternateIcons
    }

    var currentIcon: AppIcon {
        AppIcon(alternateIconName: UIApplication.shared.alternateIconName)
    }

    func apply(_ icon: AppIcon) async throws {
        // setAlternateIconName의 completion handler는 옵셔널이라 async 형태로 자동 브리징되지 않는다.
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UIApplication.shared.setAlternateIconName(icon.alternateIconName) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}
