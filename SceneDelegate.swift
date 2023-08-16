//
//  SceneDelegate.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        if let appearance = UserDefaults.standard.value(forKey: "themeStateEnum") as? Int {
            let theme = Appearance(rawValue: appearance) ?? Appearance.system

            switch theme {
            case .dark: window?.overrideUserInterfaceStyle = .dark
            case .system: window?.overrideUserInterfaceStyle = .unspecified
            case .light: window?.overrideUserInterfaceStyle = .light
            }
        } else {
            UserDefaults.standard.set(Appearance.system.rawValue, forKey: "themeStateEnum")
        }

        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        window?.rootViewController = ContainerViewController(withLoadingView: true)
        window?.makeKeyAndVisible()
    }
    
    func updateRootViewController(_ viewController: UIViewController) {
        window?.rootViewController = UINavigationController(rootViewController: viewController)
        window?.makeKeyAndVisible()
        
        if !NetworkMonitor.shared.isConnected {
            viewController.displayAlert(withTitle: nil, withMessage: AppStrings.Alerts.Subtitle.network, withPrimaryActionText: AppStrings.Alerts.Actions.settings, withSecondaryActionText: AppStrings.Alerts.Actions.ok, style: .default) {
                
            }
        }
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

