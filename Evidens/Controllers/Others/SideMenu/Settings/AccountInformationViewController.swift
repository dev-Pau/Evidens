//
//  AccountInformationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit
import Firebase
import MessageUI

class AccountInformationViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let kindSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        label.text = AppStrings.Opening.logInEmailPlaceholder
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private let chevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = K.Colors.separatorColor
        return iv
    }()
    
    private let usernameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        label.text = AppStrings.Opening.usernamePlaceholder
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var usernameUserLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular)
        label.text = AppStrings.Global.add
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUsernameTouch)))
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var emailUserLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular)
        label.text = AppStrings.Global.add
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEmailTouch)))
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 1
        return label
    }()
    
    private let accountConditionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
       
        label.text = AppStrings.User.Changes.accountPhase
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var accountConditionStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular)
        label.textAlignment = .right
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAccountPhase)))
        return label
    }()
    
    private let accountConditionDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 14, scaleStyle: .title2, weight: .regular)
        label.textAlignment = .right
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var logoutLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        
        label.text = AppStrings.Opening.logOut
        label.textColor = .systemRed
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
        label.numberOfLines = 0
        return label
    }()
    
    private let providerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = AppStrings.Debug.provider
        label.textColor = .label
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var providerImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.isUserInteractionEnabled = true
        image.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleImageTap)))
        image.clipsToBounds = true
        return image
    }()
    
    
    private let usernameChevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = K.Colors.separatorColor
        return iv
    }()

    private let phaseChevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = K.Colors.separatorColor
        return iv
    }()

    private let providerChevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = K.Colors.separatorColor
        return iv
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getEmail()
    }
    
    private func getEmail() {
        view.backgroundColor = .systemBackground
        configureNavigationBar()
        
        guard NetworkMonitor.shared.isConnected else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.network) { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.navigationController?.popViewController(animated: true)
            }
            return
        }
        
        AuthService.firebaseUser { [weak self] user in
            guard let user else { return }
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.emailUserLabel.text = user.email
                strongSelf.configure(with: user)
            }
        }
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.account
    }
    
    private func configure(with user: Firebase.User) {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        
        scrollView.addSubviews(kindLabel, kindSeparator, emailLabel, emailUserLabel, chevronImage, usernameLabel, usernameUserLabel, accountConditionLabel, accountConditionDescription, accountConditionLabel, accountConditionStateLabel, providerLabel, providerImage, logoutLabel, usernameChevronImage, phaseChevronImage, providerChevronImage)

        emailLabel.setContentHuggingPriority(.required, for: .horizontal)
        emailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        usernameLabel.setContentHuggingPriority(.required, for: .horizontal)
        usernameLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        accountConditionLabel.setContentHuggingPriority(.required, for: .horizontal)
        accountConditionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        providerLabel.setContentHuggingPriority(.required, for: .horizontal)
        providerLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let size: CGFloat = UIDevice.isPad ? 25 : 20
        
        NSLayoutConstraint.activate([
            kindLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            kindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            kindLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            kindSeparator.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 10),
            kindSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            kindSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            kindSeparator.heightAnchor.constraint(equalToConstant: 0.4),
            
            emailLabel.topAnchor.constraint(equalTo: kindSeparator.bottomAnchor, constant: 30),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            emailUserLabel.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
            emailUserLabel.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 10),
            emailUserLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -10),
            
            chevronImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            chevronImage.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: size),
            chevronImage.heightAnchor.constraint(equalToConstant: size),

            usernameLabel.topAnchor.constraint(equalTo: emailUserLabel.bottomAnchor, constant: 30),
            usernameLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            usernameLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            usernameChevronImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            usernameChevronImage.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            usernameChevronImage.widthAnchor.constraint(equalToConstant: size),
            usernameChevronImage.heightAnchor.constraint(equalToConstant: size),

            usernameUserLabel.centerYAnchor.constraint(equalTo: usernameLabel.centerYAnchor),
            usernameUserLabel.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 10),
            usernameUserLabel.trailingAnchor.constraint(equalTo: usernameChevronImage.leadingAnchor, constant: -10),

            accountConditionLabel.topAnchor.constraint(equalTo: usernameUserLabel.bottomAnchor, constant: 30),
            accountConditionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            accountConditionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),

            accountConditionStateLabel.topAnchor.constraint(equalTo: accountConditionLabel.topAnchor),
            accountConditionStateLabel.leadingAnchor.constraint(equalTo: accountConditionLabel.trailingAnchor, constant: 10),
            accountConditionStateLabel.trailingAnchor.constraint(equalTo: phaseChevronImage.leadingAnchor, constant: -10),

            phaseChevronImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            phaseChevronImage.centerYAnchor.constraint(equalTo: accountConditionLabel.centerYAnchor),
            phaseChevronImage.widthAnchor.constraint(equalToConstant: size),
            phaseChevronImage.heightAnchor.constraint(equalToConstant: size),

            providerLabel.topAnchor.constraint(equalTo: accountConditionStateLabel.bottomAnchor, constant: 30),
            providerLabel.leadingAnchor.constraint(equalTo: accountConditionLabel.leadingAnchor),
            providerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            providerImage.centerYAnchor.constraint(equalTo: providerLabel.centerYAnchor),
            providerImage.trailingAnchor.constraint(equalTo: providerChevronImage.leadingAnchor, constant: -10),
            providerImage.widthAnchor.constraint(equalToConstant: size),
            providerImage.heightAnchor.constraint(equalToConstant: size),
            
            phaseChevronImage.trailingAnchor.constraint(equalTo: phaseChevronImage.leadingAnchor, constant: -10),
            phaseChevronImage.centerYAnchor.constraint(equalTo: accountConditionLabel.centerYAnchor),
            phaseChevronImage.widthAnchor.constraint(equalToConstant: size),
            phaseChevronImage.heightAnchor.constraint(equalToConstant: size),

            providerChevronImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            providerChevronImage.centerYAnchor.constraint(equalTo: providerLabel.centerYAnchor),
            providerChevronImage.widthAnchor.constraint(equalToConstant: size),
            providerChevronImage.heightAnchor.constraint(equalToConstant: size),

            logoutLabel.topAnchor.constraint(equalTo: providerLabel.bottomAnchor, constant: 50),
            logoutLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])

        usernameUserLabel.text = currentUser.getUsername()
        accountConditionStateLabel.text = currentUser.phase.content

        kindLabel.text = AppStrings.Settings.accountInfoContent

        for userInfo in user.providerData {
            let providerID = userInfo.providerID

            if providerID.contains(Provider.google.id) {
                providerImage.image = UIImage(named: AppStrings.Assets.google)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
            } else if providerID.contains(Provider.apple.id) {
                providerImage.image = UIImage(systemName: AppStrings.Icons.circleA, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
            } else if providerID.contains(Provider.password.id) {
                providerImage.image = UIImage(systemName: AppStrings.Icons.envelope, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(K.Colors.primaryGray)
            }
        }
        
        scrollView.resizeContentSize()
    }

    @objc func handleEmailTouch() {
        AuthService.providerKind { [weak self] provider in
            guard let strongSelf = self else { return }
            guard provider == .password else {
                strongSelf.displayAlert(withTitle: provider.title, withMessage: provider.content)
                return
            }
            
            let controller = ConfirmPasswordViewController()
            let navVC = UINavigationController(rootViewController: controller)
            navVC.modalPresentationStyle = .fullScreen
            strongSelf.present(navVC, animated: true)
        }
    }
    
    @objc func handleLogout() {
        
        displayAlert(withTitle: AppStrings.Opening.logOut, withMessage: AppStrings.Alerts.Subtitle.logout, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.Opening.logOut, style: .destructive) { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.logout()
            let controller = OpeningViewController()
            let sceneDelegate = strongSelf.view.window?.windowScene?.delegate as? SceneDelegate
            sceneDelegate?.updateRootViewController(controller)
        }
    }
    
    @objc func handleAccountPhase() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        switch currentUser.phase {
        case .category, .name, .username, .identity, .deactivate, .ban, .deleted:
            break
        case .review:
            displayAlert(withTitle: currentUser.phase.content)
        case .verified:
            displayAlert(withTitle: currentUser.phase.content)
        case .pending:
            let controller = VerificationViewController(user: currentUser, comesFromMainScreen: true)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    @objc func handleUsernameTouch() {
        displayAlert(withTitle: AppStrings.User.Changes.googleTitle, withMessage: AppStrings.User.Changes.username, withPrimaryActionText: AppStrings.Global.cancel, withSecondaryActionText: AppStrings.SideMenu.contact, style: .cancel) { [weak self] in
            guard let strongSelf = self else { return }
            if MFMailComposeViewController.canSendMail() {
                let controller = MFMailComposeViewController()
                
                #if DEBUG
                controller.setToRecipients([AppStrings.App.personalMail])
                #else
                controller.setToRecipients([AppStrings.App.personalMail])
                #endif
                
                controller.mailComposeDelegate = self
                strongSelf.present(controller, animated: true)
            } else {
                return
            }
        }
    }
    
    @objc func handleImageTap() {
        showProgressIndicator(in: view)
        
        AuthService.firebaseUser { [weak self] user in
            guard let strongSelf = self else { return }
            strongSelf.dismissProgressIndicator()
            
            guard let user else { return }

            for userInfo in user.providerData {
                let providerID = userInfo.providerID

                if providerID.contains(Provider.google.id) {
                    strongSelf.displayAlert(withTitle: AppStrings.Provider.google)
                } else if providerID.contains(Provider.apple.id) {
                    strongSelf.displayAlert(withTitle: AppStrings.Provider.apple)
                } else if providerID.contains(Provider.password.id) {
                    strongSelf.displayAlert(withTitle: AppStrings.Provider.password)
                }
            }
        }
    }
}


extension AccountInformationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

