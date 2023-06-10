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

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let titleLabel: UILabel = {
        let label = CustomLabel(placeholder: "You just completed the registration process")
        return label
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()

        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .label

        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Help", attributes: container)
     
        button.isUserInteractionEnabled = true
        
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.text = "Thanks for completing the registration process. We are reviewing your documentation. Upon verifying your identity, we will send you an email granting you access to all features."
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.systemBackground, for: .normal)
        button.backgroundColor = .label
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        
        UserDefaults.standard.set(user.uid, forKey: "uid")
        UserDefaults.standard.set("\(user.firstName ?? "") \(user.lastName ?? "")", forKey: "name")
        UserDefaults.standard.set(user.profileImageUrl!, forKey: "userProfileImageUrl")
        
        configureUI()
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
        helpButton.menu = addMenuItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    private func configureUI() {
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(titleLabel, descriptionLabel, continueButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: view.frame.width * 0.8),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            continueButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            continueButton.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            continueButton.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
    }
    
    @objc func handleContinue() {
        let controller = ContainerViewController()
        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: false)
    }
    
    private func addMenuItems() -> UIMenu {
        let menuItems = UIMenu(options: .displayInline, children: [
            UIAction(title: "Contact Support", image: UIImage(systemName: "tray.fill", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                if MFMailComposeViewController.canSendMail() {
                    let controller = MFMailComposeViewController()
                    controller.setToRecipients(["support@myevidens.com"])
                    controller.mailComposeDelegate = self
                    self.present(controller, animated: true)
                } else {
                    print("Device cannot send email")
                }
            }),
            
            UIAction(title: "Log Out", image: UIImage(systemName: "arrow.right.to.line", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))!, handler: { _ in
                AuthService.logout()
                AuthService.googleLogout()
                let controller = OpeningViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
        ])
        return menuItems
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
