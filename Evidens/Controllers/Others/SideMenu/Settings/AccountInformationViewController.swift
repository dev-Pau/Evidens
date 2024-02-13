//
//  AccountInformationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit
import Firebase

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
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
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
    
    private let emailConditionTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
        tv.isSelectable = false
        tv.isUserInteractionEnabled = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = .zero
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = .zero
        return tv
    }()
    
    private let chevronImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        iv.tintColor = separatorColor
        return iv
    }()
    
    private let phaseImage: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.contentMode = .center
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var emailUserLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.text = AppStrings.Global.add
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEmailTouch)))
        label.textColor = primaryGray
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
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textAlignment = .right
        label.textColor = primaryGray
        label.numberOfLines = 1
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAccountPhase)))
        return label
    }()
    
    private var accountConditionTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
        tv.isSelectable = false
        tv.isUserInteractionEnabled = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = .zero
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = .zero
        return tv
    }()
    
    private let accountConditionDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textAlignment = .right
        label.textColor = primaryGray
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
    
    private let emailSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
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
    
    private let providerImage: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .center
        image.clipsToBounds = true
        return image
    }()
    
    private let providerSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let providerKindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        label.textColor = primaryGray
        label.numberOfLines = 1
        return label
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
        
        scrollView.addSubviews(kindLabel, kindSeparator, emailLabel, emailUserLabel, chevronImage, emailConditionTextView, accountConditionLabel, emailSeparatorView, accountConditionDescription, accountConditionLabel, accountConditionStateLabel, accountConditionTextView, providerSeparator, phaseImage, providerLabel, providerKindLabel, providerImage, logoutLabel)

        emailLabel.setContentHuggingPriority(.required, for: .horizontal)
        emailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        accountConditionLabel.setContentHuggingPriority(.required, for: .horizontal)
        accountConditionLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        providerLabel.setContentHuggingPriority(.required, for: .horizontal)
        providerLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        let size: CGFloat = UIDevice.isPad ? 14 : 20
        
        NSLayoutConstraint.activate([
            kindLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            kindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            kindLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            kindSeparator.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 10),
            kindSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            kindSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            kindSeparator.heightAnchor.constraint(equalToConstant: 0.4),
            
            emailLabel.topAnchor.constraint(equalTo: kindSeparator.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            emailUserLabel.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
            emailUserLabel.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 10),
            emailUserLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -15),
            
            chevronImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            chevronImage.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: size),
            chevronImage.heightAnchor.constraint(equalToConstant: size),

            emailConditionTextView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 15),
            emailConditionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            emailConditionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            emailSeparatorView.topAnchor.constraint(equalTo: emailConditionTextView.bottomAnchor, constant: 20),
            emailSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emailSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emailSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            accountConditionLabel.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor, constant: 20),
            accountConditionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            accountConditionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            phaseImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            phaseImage.centerYAnchor.constraint(equalTo: accountConditionStateLabel.centerYAnchor),
            phaseImage.widthAnchor.constraint(equalToConstant: size),
            phaseImage.heightAnchor.constraint(equalToConstant: size),

            accountConditionStateLabel.topAnchor.constraint(equalTo: accountConditionLabel.topAnchor),
            accountConditionStateLabel.leadingAnchor.constraint(equalTo: accountConditionLabel.trailingAnchor, constant: 10),
            accountConditionStateLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -15),
            
            accountConditionTextView.topAnchor.constraint(equalTo: accountConditionLabel.bottomAnchor, constant: 15),
            accountConditionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            accountConditionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            providerSeparator.topAnchor.constraint(equalTo: accountConditionTextView.bottomAnchor, constant: 20),
            providerSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            providerSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            providerSeparator.heightAnchor.constraint(equalToConstant: 0.3333),
            
            providerLabel.topAnchor.constraint(equalTo: providerSeparator.bottomAnchor, constant: 20),
            providerLabel.leadingAnchor.constraint(equalTo: accountConditionLabel.leadingAnchor),
            providerLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            providerImage.centerYAnchor.constraint(equalTo: providerLabel.centerYAnchor),
            providerImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            providerImage.widthAnchor.constraint(equalToConstant: size),
            providerImage.heightAnchor.constraint(equalToConstant: size),
            
            providerKindLabel.centerYAnchor.constraint(equalTo: providerLabel.centerYAnchor),
            providerKindLabel.trailingAnchor.constraint(equalTo: providerImage.leadingAnchor, constant: -15),

            logoutLabel.topAnchor.constraint(equalTo: providerLabel.bottomAnchor, constant: 30),
            logoutLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])

        let font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        
        let verificationString = NSMutableAttributedString(string: AppStrings.User.Changes.verifyRules/* + " " + AppStrings.Content.Empty.learn*/, attributes: [.font: font, .foregroundColor: primaryGray])

        accountConditionStateLabel.text = currentUser.phase.content
        accountConditionTextView.attributedText = verificationString

        kindLabel.text = AppStrings.Settings.accountInfoContent
        phaseImage.tintColor = primaryGray
        
        switch currentUser.phase {

        case .pending:
            phaseImage.image = UIImage(systemName: AppStrings.Icons.circle, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        case .review:
            phaseImage.image = UIImage(systemName: AppStrings.Icons.circle, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        case .verified:
            phaseImage.image = UIImage(systemName: AppStrings.Icons.checkmarkCircleFill, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysTemplate)
        default:
            break
        }

        let emailString = NSMutableAttributedString(string: AppStrings.User.Changes.changesRules, attributes: [.font: font, .foregroundColor: primaryGray])
        emailConditionTextView.attributedText = emailString

        for userInfo in user.providerData {
            let providerID = userInfo.providerID

            if providerID.contains(Provider.google.id) {
                providerImage.image = UIImage(named: AppStrings.Assets.google)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
                providerKindLabel.text = AppStrings.Provider.google
            } else if providerID.contains(Provider.apple.id) {
                providerImage.image = UIImage(systemName: AppStrings.Icons.circleA, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(.label)
                providerKindLabel.text = AppStrings.Provider.apple
            } else if providerID.contains(Provider.password.id) {
                providerImage.image = UIImage(systemName: AppStrings.Icons.fillEnvelope, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(primaryGray)
                providerKindLabel.text = AppStrings.Provider.password
            }
        }
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
            AuthService.logout()
            AuthService.googleLogout()
            UserDefaults.resetDefaults()
            let controller = OpeningViewController()
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            strongSelf.present(nav, animated: true)
        }
    }
    
    @objc func handleAccountPhase() {
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        switch currentUser.phase {
        case .category, .details, .identity, .review, .verified, .deactivate, .ban, .deleted:
            break
        case .pending:
            let controller = VerificationViewController(user: currentUser, comesFromMainScreen: true)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}
