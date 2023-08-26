//
//  UIViewController+Ext.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 26/7/23.
//

import UIKit
import SafariServices


fileprivate var progressView: ProgressIndicatorView!

extension UIViewController {
    
    func addNavigationBarLogo(withTintColor color: UIColor) {
        if let logo = UIImage(named: AppStrings.Assets.blackLogo)?.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32)) {
            let imageView = UIImageView(image: logo.withTintColor(color))
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        }
    }
    
    func addNavigationBarLogo(withImage image: String, withTintColor color: UIColor) {
        if let logo = UIImage(named: image)?.scalePreservingAspectRatio(targetSize: CGSize(width: 32, height: 32)) {
            let imageView = UIImageView(image: logo.withTintColor(color))
            imageView.contentMode = .scaleAspectFit
            navigationItem.titleView = imageView
        }
    }
    
    func setUserDefaults(for user: User) {
        guard let uid = user.uid, let firstName = user.firstName, let lastName = user.lastName else { return }
        
        UserDefaults.standard.set(uid, forKey: "uid")
        print("we set user uid \(uid)")
        UserDefaults.standard.set(firstName + " " + lastName, forKey: "name")
        
        if let profile = user.profileUrl, profile != String() {
            UserDefaults.standard.set(profile, forKey: "profileUrl")
        }
        
        if let banner = user.bannerUrl, banner != String() {
            UserDefaults.standard.set(banner, forKey: "bannerUrl")
        }
        
        let encodedData = try? JSONEncoder().encode(user.phase)
        UserDefaults.standard.set(encodedData, forKey: "phase")
        
        CrashlyticsManager.shared.setUserId(userId: uid)
    }
    
    func getPhase() -> UserPhase? {
        if let data = UserDefaults.standard.data(forKey: "phase"),
           let decodedPhase = try? JSONDecoder().decode(UserPhase.self, from: data) {
            return decodedPhase
        }
        
        return nil
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
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: AppStrings.Alerts.Actions.ok, style: UIAlertAction.Style.default, handler: nil))
            strongSelf.present(alert, animated: true, completion: nil)
        }
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
    
    func showProgressIndicator(in view: UIView) {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            progressView = ProgressIndicatorView(frame: view.bounds)
            window.addSubview(progressView)
            progressView.show()
        }
    }
    
    func dismissProgressIndicator() {
        progressView.dismiss()
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
