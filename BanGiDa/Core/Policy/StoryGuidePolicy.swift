//
//  StoryGuidePolicy.swift
//  BanGiDa
//

import Foundation
import CoreKit

enum StoryGuidePolicy {
    static let currentVersion = 2 // 1: 사진 정책만, 2: 댓글 정책 포함

    /// 레거시 불리언 동의(`storyAgreement`)를 버전 1로 승격한다.
    ///
    /// 뷰가 렌더링마다 레거시 키를 확인하게 두면 두 가지 문제가 생긴다.
    /// UserDefaults를 매번 읽는 비용도 있지만, 더 중요한 건 레거시 경로에서
    /// `@AppStorage` 값을 읽지 않고 빠져나가면 SwiftUI가 의존성을 등록하지 못해
    /// 동의 후에도 화면이 갱신되지 않는다는 점이다. 마이그레이션은 최초 1회로 끝낸다.
    static func migrateLegacyAgreementIfNeeded(defaults: UserDefaults = .standard) {
        let versionKey = UserDefaultsKey.storyAgreementVersion.rawValue

        guard defaults.object(forKey: versionKey) == nil else { return }
        guard defaults.bool(forKey: UserDefaultsKey.storyAgreement.rawValue) else { return }

        defaults.set(1, forKey: versionKey)
    }
}
