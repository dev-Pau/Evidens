//
//  WaitingVerificationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 4/8/22.
//

import UIKit
import MessageUI
import PhotosUI

class WaitingVerificationViewController: UIViewController {
    private let user: User
    private let helperBottomRegistrationMenuLauncher = HelperBottomMenuLauncher()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let welcomeText: UILabel = {
        let label = CustomLabel(placeholder: "Welcome!")
        return label
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()

        button.configuration?.baseBackgroundColor = lightGrayColor
        button.configuration?.baseForegroundColor = .black

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Help", attributes: container)
     
        button.isUserInteractionEnabled = true

        button.addTarget(self, action: #selector(handleHelp), for: .touchUpInside)
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You just finished the registration process to join the MyEvidens community."
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "We are reviewing your documentation. Upon verifying your identity, we will send you an email granting you access to MyEvidens."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        label.textAlignment = .left
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        helperBottomRegistrationMenuLauncher.delegate = self
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func configureNavigationBar() {
        title = "Verification"
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    private func configureUI() {
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(welcomeText, titleLabel, subtitleLabel)
        
        NSLayoutConstraint.activate([
            welcomeText.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            welcomeText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            welcomeText.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            titleLabel.topAnchor.constraint(equalTo: welcomeText.bottomAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
        ])
    }
    
    @objc func handleHelp() {
        helperBottomRegistrationMenuLauncher.showImageSettings(in: view)
    }
}

extension WaitingVerificationViewController: HelperBottomMenuLauncherDelegate {
    func didTapContactSupport() {
        if MFMailComposeViewController.canSendMail() {
            let controller = MFMailComposeViewController()
            controller.setToRecipients(["support@myevidens.com"])
            controller.mailComposeDelegate = self
            present(controller, animated: true)
        } else {
            print("Device cannot send email")
        }
    }
    
    func didTapLogout() {
        AuthService.logout()
        AuthService.googleLogout()
        let controller = WelcomeViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true)
    }
}

extension WaitingVerificationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}
