//
//  AccountInformationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

class AccountInformationViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private var verificationDetailsMenu = ContextMenu(display: .join)
    private let emailDetailsMenu = ContextMenu(display: .email)
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = AppStrings.Opening.logInEmailPlaceholder
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let emailConditionTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
        tv.isSelectable = true
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
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.image = UIImage(systemName: AppStrings.Icons.rightChevron, withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.withRenderingMode(.alwaysOriginal).withTintColor(separatorColor!)
        return iv
    }()
    
    private lazy var emailUserLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.text = AppStrings.Global.add
        label.textAlignment = .right
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleEmailTouch)))
        label.textColor = primaryColor
        label.numberOfLines = 0
        return label
    }()
    
    private let accountConditionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = AppStrings.User.Changes.condition
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var accountConditionStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        label.textColor = primaryColor
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleAccountPhase)))
        return label
    }()
    
    private var accountConditionTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
        tv.isSelectable = true
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
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textAlignment = .right
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var logoutLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .semibold)
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        AuthService.userEmail { [weak self] email in
            guard let strongSelf = self else { return }
            strongSelf.emailUserLabel.text = email
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        title = AppStrings.Title.account
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        
        scrollView.addSubviews(kindLabel, emailLabel, emailUserLabel, chevronImage, emailConditionTextView, accountConditionLabel, emailSeparatorView, accountConditionDescription, accountConditionLabel, accountConditionStateLabel, accountConditionTextView, logoutLabel)
        
        emailLabel.sizeToFit()
        emailLabel.setContentHuggingPriority(.required, for: .horizontal)
        emailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        emailLabel.sizeToFit()
        emailLabel.setContentHuggingPriority(.required, for: .horizontal)
        emailLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            kindLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            kindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            kindLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            emailLabel.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            emailLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            emailUserLabel.topAnchor.constraint(equalTo: emailLabel.topAnchor),
            emailUserLabel.leadingAnchor.constraint(equalTo: emailLabel.trailingAnchor, constant: 10),
            emailUserLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -10),
            
            chevronImage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            chevronImage.centerYAnchor.constraint(equalTo: emailLabel.centerYAnchor),
            chevronImage.widthAnchor.constraint(equalToConstant: 14),
            chevronImage.heightAnchor.constraint(equalToConstant: 17),

            emailConditionTextView.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            emailConditionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            emailConditionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            emailSeparatorView.topAnchor.constraint(equalTo: emailConditionTextView.bottomAnchor, constant: 10),
            emailSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emailSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emailSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            accountConditionLabel.topAnchor.constraint(equalTo: emailSeparatorView.bottomAnchor, constant: 10),
            accountConditionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            accountConditionLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            accountConditionStateLabel.topAnchor.constraint(equalTo: accountConditionLabel.topAnchor),
            accountConditionStateLabel.leadingAnchor.constraint(equalTo: accountConditionLabel.trailingAnchor, constant: 10),
            accountConditionStateLabel.trailingAnchor.constraint(equalTo: chevronImage.leadingAnchor, constant: -10),
            
            accountConditionTextView.topAnchor.constraint(equalTo: accountConditionLabel.bottomAnchor, constant: 10),
            accountConditionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            accountConditionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            logoutLabel.topAnchor.constraint(equalTo: accountConditionTextView.bottomAnchor, constant: 25),
            logoutLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
        
        
        guard let tab = tabBarController as? MainTabController else { return }
        guard let currentUser = tab.user else { return }
        
        
        let verificationString = NSMutableAttributedString(string: AppStrings.User.Changes.verifyRules + " " + AppStrings.Content.Empty.learn, attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel])
        verificationString.addAttributes([.foregroundColor: primaryColor, .link: NSAttributedString.Key("presentCommunityInformation")], range: (verificationString.string as NSString).range(of: AppStrings.Content.Empty.learn))
    
        accountConditionStateLabel.text = currentUser.phase.content
        accountConditionTextView.attributedText = verificationString
        accountConditionTextView.delegate = self
        kindLabel.text = AppStrings.Settings.accountInfoContent
        
        let emailString = NSMutableAttributedString(string: AppStrings.User.Changes.changesRules + " " + AppStrings.Content.Empty.learn, attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel])
        emailString.addAttributes([.foregroundColor: primaryColor, .link: NSAttributedString.Key("presentCommunityInformation")], range: (emailString.string as NSString).range(of: AppStrings.Content.Empty.learn))

        emailConditionTextView.attributedText = emailString
        emailConditionTextView.delegate = self
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
        case .category, .details, .identity, .review, .verified, .deactivate, .ban:
            break
        case .pending:
            let controller = VerificationViewController(user: currentUser)
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
}


extension AccountInformationViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "presentCommunityInformation" {
            if textView == accountConditionTextView {
                verificationDetailsMenu.showImageSettings(in: view)
            } else {
                emailDetailsMenu.showImageSettings(in: view)
            }
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}


