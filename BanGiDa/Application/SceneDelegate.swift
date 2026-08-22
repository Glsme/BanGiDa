//
//  SceneDelegate.swift
//  BanGiDa
//
//  Created by Seokjune Hong on 2022/09/08.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @Injected private var checkUserRegistrationUseCase: CheckUserRegistrationUseCase
    @Injected private var createAuthUserUseCase: CreateAuthUserUseCase
    @Injected private var syncAppIconUseCase: SyncAppIconUseCase

    private var hasSyncedAppIcon = false

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: scene)
        window?.rootViewController = MainTabViewController()
        window?.makeKeyAndVisible()
        checkUserRegistration()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        syncAppIconIfNeeded()
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}

private extension SceneDelegate {
    /// 아이콘 교체는 시스템 알림을 동반하므로 백그라운드 복귀마다가 아니라 콜드스타트에 한 번만 수행한다.
    func syncAppIconIfNeeded() {
        guard !hasSyncedAppIcon else { return }
        hasSyncedAppIcon = true

        Task {
            do {
                try await syncAppIconUseCase.execute()
            } catch {
                print("syncAppIcon Error: ", error)
            }
        }
    }

    func checkUserRegistration() {
        Task {
            do {
                guard try await !checkUserRegistrationUseCase.execute() else { return }
                try await createAuthUserUseCase.execute()
            } catch {
                print("checkUserRegistration Error: ", error)
            }
        }
    }
}

