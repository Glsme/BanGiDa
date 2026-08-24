//
//  AppDelegate.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseFirestore
import FirebaseMessaging
import RealmSwift
import Domain

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    @Injected private var analyticsRepository: AnalyticsRepository
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        configureRealmMigration()
        IQKeyboardManager.shared.enable = true
        _ = AppDIContainer.shared
        
        FirebaseApp.configure()
        _ = Firestore.firestore()
        
        //원격 알림 시스템에 앱을 등록
        if #available(iOS 10.0, *) {
          // For iOS 10 display notification (sent via APNS)
          UNUserNotificationCenter.current().delegate = self

          let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
          UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
          )
        } else {
          let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
          application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        //메시지 대리자 설정
        Messaging.messaging().delegate = self
        
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        analyticsRepository.recordError(error, userInfo: ["function": "\(#function)"])
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    private func configureRealmMigration() {
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock: { migration, oldVersion in
            if oldVersion < 1 {
                migration.enumerateObjects(ofType: Diary.className()) { _, newObject in
                    newObject?["repeatRule"] = AlarmRepeat.none.rawValue
                }
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.list, .banner, .sound])
    }
    
    //유저가 푸시를 클릭했을 때에만 수신 확인 가능
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        guard userInfo["type"] as? String == "story_comment" else {
            completionHandler()
            return
        }

        // storyID는 payload에 포함되지만, 커서 기반 피드에서 임의 스토리까지 이동하려면
        // 모든 페이지를 순차 조회해야 한다. 단일 스토리 상세 화면이 생기기 전까지는 탭만 전환한다.
        DispatchQueue.main.async { [weak self] in
            self?.selectStoryTab()
            completionHandler()
        }
    }

    private func selectStoryTab() {
        let windowScene = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first

        guard let rootViewController = windowScene?.windows.first(where: \.isKeyWindow)?.rootViewController,
              let tabViewController = rootViewController as? MainTabViewController else {
            return
        }

        tabViewController.selectedIndex = MainTabViewController.Tab.story.rawValue
    }
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken, !fcmToken.isEmpty,
              let updateFCMTokenUseCase = AppDIContainer.shared.container.resolve(UpdateFCMTokenUseCase.self) else {
            return
        }

        Task { @MainActor [weak self] in
            do {
                try await updateFCMTokenUseCase.execute(token: fcmToken)
            } catch {
                self?.analyticsRepository.recordError(
                    error,
                    userInfo: ["function": #function]
                )
            }
        }
    }
}
