//
//  UIViewController+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/23.
//

import UIKit
import SafariServices

fileprivate var progressView: ProgressIndicatorView?

/// An extension of UIViewController.
extension UIViewController {
    
    /// Adds a logo to the navigation bar with a specified tint color.
    ///
    /// - Parameters:
    ///   - color: The tint color for the logo.
    func addNavigationBarLogo(withTintColor color: UIColor) {
        if let logo = UIImage(named: AppStrings.Assets.blackLogo)?.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32)) {
            let imageView = UIImageView(image: logo.withTintColor(color))
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        }
    }
    
    /// Adds a custom logo to the navigation bar with a specified tint color.
    ///
    /// - Parameters:
    ///   - image: The name of the image to be used as the logo.
    ///   - color: The tint color for the logo.
    func addNavigationBarLogo(withImage image: String, withTintColor color: UIColor) {
        if let logo = UIImage(named: image)?.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32)) {
            let imageView = UIImageView(image: logo.withTintColor(color))
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        }
    }
    
    /// Sets user-related information in UserDefaults and Crashlytics.
    ///
    /// - Parameters:
    ///   - user: The user object containing information to be stored.
    func setUserDefaults(for user: User) {
        guard let uid = user.uid, let firstName = user.firstName, let lastName = user.lastName else { return }
        
        UserDefaults.standard.set(uid, forKey: "uid")

        UserDefaults.standard.set(firstName + " " + lastName, forKey: "name")
        
        if let profile = user.profileUrl, profile != String() {
            UserDefaults.standard.set(profile, forKey: "profileUrl")
        } else {
            UserDefaults.standard.set(String(), forKey: "profileUrl")
        }
        
        if let banner = user.bannerUrl, banner != String() {
            UserDefaults.standard.set(banner, forKey: "bannerUrl")
        } else {
            UserDefaults.standard.set(String(), forKey: "bannerUrl")
        }
        
        if let username = user.username {
            UserDefaults.standard.set(username, forKey: "username")
        }
        
        let encodedData = try? JSONEncoder().encode(user.phase)
        UserDefaults.standard.set(encodedData, forKey: "phase")
        
        CrashlyticsManager.shared.setUserId(userId: uid)
        
        let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate
        sceneDelegate?.addUserListener()
        
    }
    
    /// Presents a Safari View Controller with the specified URL.
    ///
    /// - Parameters:
    ///   - url: The URL to be displayed in the Safari View Controller.
    func presentSafariViewController(withURL url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
    
    /// Displays an alert with the specified title and optional message.
    ///
    /// - Parameters:
    ///   - title: The title of the alert.
    ///   - message: The optional message displayed in the alert.
    ///   - completion: A closure to be executed after the user taps the "OK" button.
    func displayAlert(withTitle title: String, withMessage message: String? = nil, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: AppStrings.Alerts.Actions.ok, style: UIAlertAction.Style.default) { [weak self] _ in
                guard let _ = self, let completion else { return }
                completion()
            })
            strongSelf.present(alert, animated: true, completion: nil)
        }
    }
    
    /// Displays an alert with the specified title, message, and action buttons.
    ///
    /// - Parameters:
    ///   - title: The title of the alert. Defaults to `nil`.
    ///   - message: The message displayed in the alert. Defaults to `nil`.
    ///   - primaryText: The text for the primary action button.
    ///   - secondaryText: The text for the secondary action button.
    ///   - style: The style of the secondary action button.
    ///   - completion: A closure to be executed when the secondary action button is tapped.
    func displayAlert(withTitle title: String? = nil, withMessage message: String? = nil, withPrimaryActionText primaryText: String, withSecondaryActionText secondaryText: String, style: UIAlertAction.Style, completion: @escaping() -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: primaryText, style: UIAlertAction.Style.default, handler: nil))

        alert.addAction(UIAlertAction(title: secondaryText, style: style) { [weak self] _ in
            guard let _ = self else { return }
            completion()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Displays a progress indicator view on the specified view.
    ///
    /// - Parameters:
    ///   - view: The UIView on which the progress indicator will be displayed.
    func showProgressIndicator(in view: UIView) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            progressView = ProgressIndicatorView(frame: window.frame)
            window.addSubview(progressView!)
            progressView!.show()
        }
    }
    
    /// Dismisses the currently displayed progress indicator view.
    func dismissProgressIndicator() {
        progressView?.dismiss()
    }

    /// The height of the status bar in the current application window.
    ///
    /// This variable retrieves the height of the status bar, which can be useful
    /// for positioning UI elements relative to the status bar.
    /// - Returns: The height of the status bar.
    var statusBarHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let statusBarManager = windowScene.statusBarManager {
            return statusBarManager.statusBarFrame.size.height
        }
        
        return 0
    }

    /// The combined height of the status bar and navigation bar.
    ///
    /// This variable calculates and returns the total height of the top bar,
    /// including the status bar and the navigation bar.
    ///
    /// - Returns: The combined height of the status bar and navigation bar.
    var topbarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0.0
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let statusBarManager = windowScene.statusBarManager {
            statusBarHeight = statusBarManager.statusBarFrame.size.height
        }
        
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
        return statusBarHeight + navigationBarHeight
    }
    
    /// The height of the visible screen area, excluding status bar, navigation bar, and tab bar.
    ///
    /// This variable calculates and returns the height of the visible screen area by subtracting
    /// the heights of the status bar, navigation bar, and tab bar from the total screen height.
    ///
    /// - Returns: The height of the visible screen area.
    var visibleScreenHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
            let statusBarHeight = window.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
            let navigationBarHeight = navigationController?.navigationBar.frame.height ?? 0
            let tabBarHeight = tabBarController?.tabBar.frame.height ?? 0
            
            let screenHeight = UIWindow.visibleScreenHeight
            let heightMinusBars = screenHeight - statusBarHeight - navigationBarHeight - tabBarHeight
            
            return heightMinusBars
        }
        
        return UIWindow.visibleScreenHeight
    }
    
    /// Logs out the user from the application.
    func logout() {
        AuthService.logout()
        AuthService.googleLogout()
    }
}
