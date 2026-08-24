//
//  FirebaseBootstrap.swift
//  BanGiDa
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging

/// Firebase 초기화와 FCM 등록 토큰 수신을 Data가 소유한다.
///
/// 원래 `AppDelegate`가 `FirebaseApp.configure()`·`Messaging` 대리자·`MessagingDelegate`
/// 채택을 직접 들고 있었다. 그러면 앱 타깃과 Data 타깃이 Firebase를 이중으로 링크하게 되는데,
/// Firebase 산출물은 정적이라 어느 구성으로도 링크가 성립하지 않는다.
/// (양쪽 선언 시 duplicate symbol, 한쪽만 선언 시 Obj-C 내부 심볼 undefined,
///  동적 강제 시 FirebaseFirestore 자체 링크 실패)
/// Firebase를 만지는 타깃을 Data 하나로 모아 문제를 없앤다.
package final class FirebaseBootstrap: NSObject {
    package static let shared = FirebaseBootstrap()

    /// FCM 등록 토큰이 갱신되면 호출된다. 비어 있는 토큰은 전달하지 않는다.
    package var onRegistrationTokenRefresh: ((String) -> Void)?

    private override init() {
        super.init()
    }

    package func configure() {
        FirebaseApp.configure()
        _ = Firestore.firestore()
    }

    package func startMessaging() {
        Messaging.messaging().delegate = self
    }

    package func setAPNSToken(_ deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
}

extension FirebaseBootstrap: MessagingDelegate {
    package func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken, !fcmToken.isEmpty else { return }

        onRegistrationTokenRefresh?(fcmToken)
    }
}
