//
//  VerificationRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import MessageUI
import JGProgressHUD

class VerificationRegistrationViewController: UIViewController {
    
    private var user: User
    private let progressIndicator = JGProgressHUD()
   
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .interactive
        return scrollView
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
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.showsMenuAsPrimaryAction = true
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 35, weight: .heavy)
        label.textColor = .label
        label.numberOfLines = 0
        label.text = "We need to verify your identity."
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.numberOfLines = 0
        label.text = "Please select one of the following identity document types or skip this process and complete the verification process via email."
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let informationVerificationLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = "  OR  "
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.numberOfLines = 0
        label.text = "Skip the verification process and do it later. Most features will be locked until your account is verified as a healthcare community member."
        label.textColor = .secondaryLabel
        return label
    }()
    
    private lazy var skipLabel: UILabel = {
        let label = UILabel()
        label.text = "Skip for now"
        label.sizeToFit()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .bold)
        let textRange = NSRange(location: 0, length: label.text!.count)
        let attributedText = NSMutableAttributedString(string: label.text!)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: textRange)
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textColor = .label
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSkip)))
        return label
    }()
    
    private let driverView = MERegistrationDocumentView(title: "Driver's license", image: "car")
    private let idCardView = MERegistrationDocumentView(title: "ID Card", image: "menucard")
    private let passportView = MERegistrationDocumentView(title: "Passport", image: "doc.text")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
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
        driverView.delegate = self
        idCardView.delegate = self
        passportView.delegate = self
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        view.addSubview(scrollView)
    
        scrollView.addSubviews(titleLabel, descriptionLabel, idCardView, driverView, passportView, separatorView, orLabel, emailLabel, skipLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            idCardView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            idCardView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            idCardView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            idCardView.heightAnchor.constraint(equalToConstant: 50),
            
            driverView.topAnchor.constraint(equalTo: idCardView.bottomAnchor, constant: 10),
            driverView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            driverView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            driverView.heightAnchor.constraint(equalToConstant: 50),
            
            passportView.topAnchor.constraint(equalTo: driverView.bottomAnchor, constant: 10),
            passportView.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            passportView.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            passportView.heightAnchor.constraint(equalToConstant: 50),
            
            skipLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            skipLabel.leadingAnchor.constraint(equalTo: passportView.leadingAnchor),
            skipLabel.trailingAnchor.constraint(equalTo: passportView.trailingAnchor),
            
            emailLabel.bottomAnchor.constraint(equalTo: skipLabel.topAnchor, constant: -20),
            emailLabel.leadingAnchor.constraint(equalTo: passportView.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: passportView.trailingAnchor),
            
            separatorView.bottomAnchor.constraint(equalTo: emailLabel.topAnchor, constant: -20),
            separatorView.leadingAnchor.constraint(equalTo: passportView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: passportView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            orLabel.centerXAnchor.constraint(equalTo: separatorView.centerXAnchor),
            orLabel.centerYAnchor.constraint(equalTo: separatorView.centerYAnchor),

        ])
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
                let controller = WelcomeViewController()
                let nav = UINavigationController(rootViewController: controller)
                nav.modalPresentationStyle = .fullScreen
                self.present(nav, animated: true)
            })
        ])
        return menuItems
    }
    
    @objc func handleSkip() {
        guard let uid = user.uid else { return }
        
        UserDefaults.standard.set(user.uid, forKey: "uid")
        UserDefaults.standard.set("\(user.firstName ?? "") \(user.lastName ?? "")", forKey: "name")
        UserDefaults.standard.set(user.profileImageUrl!, forKey: "userProfileImageUrl")
        
        AuthService.updateUserRegistrationDocumentationDetails(withUid: uid) { error in
            if let error = error {
                self.progressIndicator.dismiss(animated: true)
                print(error.localizedDescription)
                return
            }
        
            DatabaseManager.shared.insertUser(with: ChatUser(firstName: self.user.firstName!, lastName: self.user.lastName!, emailAddress: self.user.email!, uid: self.user.uid!, profilePictureUrl: self.user.profileImageUrl!, profession: self.user.profession!, speciality: self.user.speciality!, category: self.user.category.userCategoryString)) { uploaded in
                self.progressIndicator.dismiss(animated: true)
                if uploaded {
                    let controller = ContainerViewController()
                    controller.modalPresentationStyle = .fullScreen
                    self.present(controller, animated: false)
                }
            }
        }
    }
}

extension VerificationRegistrationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        controller.dismiss(animated: true)
    }
}

extension VerificationRegistrationViewController: MERegistrationDocumentViewDelegate {
    func didTapVerificationOption(option: String) {
        
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .label
        navigationItem.backBarButtonItem = backItem
        
        switch option {
        case "ID Card":
            let controller = IDCardViewController(user: user)
            navigationController?.pushViewController(controller, animated: true)
            
        case "Driver's license":
            let controller = DriverLicenseViewController(user: user)
            navigationController?.pushViewController(controller, animated: true)
            
        default:
            let controller = PassportViewController(user: user)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
