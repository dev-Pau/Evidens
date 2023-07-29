//
//  UIViewController+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/23.
//

import UIKit
import SafariServices

extension UIViewController {
    
    func setUserDefaults(for user: User) {
        guard let uid = user.uid, let firstName = user.firstName, let lastName = user.lastName else { return }
        
        UserDefaults.standard.set(uid, forKey: "uid")
        UserDefaults.standard.set(firstName + " " + lastName, forKey: "name")
        
        if let profile = user.profileUrl, profile != String() {
            UserDefaults.standard.set(profile, forKey: "userProfileImageUrl")
        }
    }
    
    func presentSafariViewController(withURL url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        present(safariViewController, animated: true, completion: nil)
    }
        
    func presentWebViewController(withURL url: URL) {
        let webViewController = WebViewController(url: url)
        let navVC = UINavigationController(rootViewController: webViewController)
        present(navVC, animated: true, completion: nil)
    }
    
    func displayAlert(withTitle title: String, withMessage message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: AppStrings.Alerts.Actions.ok, style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func displayAlert(withTitle title: String? = nil, withMessage message: String? = nil, withPrimaryActionText primaryText: String, withSecondaryActionText secondaryText: String, style: UIAlertAction.Style, completion: @escaping() -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: primaryText, style: UIAlertAction.Style.default, handler: nil))

        alert.addAction(UIAlertAction(title: secondaryText, style: style) { [weak self] _ in
            guard let _ = self else { return }
            completion()
        })
        
        self.present(alert, animated: true, completion: nil)
    }
    
    var statusBarHeight: CGFloat {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let statusBarManager = windowScene.statusBarManager {
            return statusBarManager.statusBarFrame.size.height
        }
        return 0

    }

    var topbarHeight: CGFloat {
        var statusBarHeight: CGFloat = 0.0
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let statusBarManager = windowScene.statusBarManager {
            statusBarHeight = statusBarManager.statusBarFrame.size.height
        }
        
        let navigationBarHeight = self.navigationController?.navigationBar.frame.height ?? 0.0
        return statusBarHeight + navigationBarHeight
    }
}
