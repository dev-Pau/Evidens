//
//  AppDelegate.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import CoreData
import UIKit
import Firebase
import GoogleSignIn

@main

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    weak var networkDelegate: NetworkDelegate?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        NetworkMonitor.shared.startMonitoring()
        NetworkMonitor.shared.delegate = self
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        if #available(iOS 15, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
            navigationBarAppearance.configureWithOpaqueBackground()
            
            let barButtonItemAppearance = UIBarButtonItemAppearance()
            barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
            navigationBarAppearance.backButtonAppearance = barButtonItemAppearance
            
            navigationBarAppearance.shadowColor = separatorColor
            navigationBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 17, weight: .heavy)]
            
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactScrollEdgeAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            
            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.shadowColor = separatorColor
            UITabBar.appearance().tintColor = primaryColor
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
            
            UITabBar.appearance().scrollEdgeAppearance?.stackedLayoutAppearance.normal.badgeBackgroundColor = .systemRed
        }

        if let _ = UserDefaults.standard.value(forKey: "uid") as? String {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
              UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
              )
            application.registerForRemoteNotifications()
        }
        
        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
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

    
    func applicationDidBecomeActive(_ application: UIApplication) {
            NotificationCenter.default.post(name: NSNotification.Name("notificationsDidChange"), object: nil)
        }
}

extension AppDelegate: UNUserNotificationCenterDelegate, MessagingDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken 
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register with push \(error.localizedDescription)")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        Messaging.messaging().token { token, error in
            if let token {
                DatabaseManager.shared.addNotificationToken(tokenID: token)
            }
        }
    }
    
    func removeFCMToken(for uid: String) {
        Messaging.messaging().deleteToken { error in
            if error == nil {
                DatabaseManager.shared.removeNotificationToken(for: uid)
            }
        }
    }
}

extension AppDelegate: NetworkMonitorDelegate {
    func connectionStatusChanged(connected: Bool) {
        networkDelegate?.didBecomeConnected()
    }
}

