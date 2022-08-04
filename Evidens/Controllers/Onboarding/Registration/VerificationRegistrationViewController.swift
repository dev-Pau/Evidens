//
//  VerificationRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import MessageUI

class VerificationRegistrationViewController: UIViewController {
    
    private var user: User
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
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()
        button.configuration?.baseBackgroundColor = lightGrayColor
        button.configuration?.baseForegroundColor = .black
        button.configuration?.cornerStyle = .capsule

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Help", attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(handleHelp), for: .touchUpInside)
        return button
    }()
    
    private let imageTextLabel: UILabel = {
        let label = UILabel()
        label.text = "We need a photo of your ID"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let cardImageView: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "menucard")!.withRenderingMode(.alwaysOriginal).withTintColor(primaryColor)
        return iv
    }()
    
    private let informationVerificationLabel: UILabel = {
        let label = UILabel()
        label.text = "We verify all members of the MyEvidens community. Please select one of the following identity document types:"
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let driverView = MERegistrationDocumentView(title: "Driver's license", image: "car")
    private let idCardView = MERegistrationDocumentView(title: "ID Card", image: "menucard")
    private let passportView = MERegistrationDocumentView(title: "Passport", image: "doc.text")
    
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
        driverView.delegate = self
        idCardView.delegate = self
        passportView.delegate = self
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        view.addSubview(scrollView)
    
        scrollView.addSubviews(cardImageView, imageTextLabel, informationVerificationLabel, idCardView, driverView, passportView)
        
        NSLayoutConstraint.activate([
            cardImageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            cardImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            cardImageView.widthAnchor.constraint(equalToConstant: 75),
            cardImageView.heightAnchor.constraint(equalToConstant: 85),
            
            imageTextLabel.topAnchor.constraint(equalTo: cardImageView.bottomAnchor, constant: 10),
            imageTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            informationVerificationLabel.topAnchor.constraint(equalTo: imageTextLabel.bottomAnchor, constant: 10),
            informationVerificationLabel.leadingAnchor.constraint(equalTo: imageTextLabel.leadingAnchor),
            informationVerificationLabel.trailingAnchor.constraint(equalTo: imageTextLabel.trailingAnchor),
            
            idCardView.topAnchor.constraint(equalTo: informationVerificationLabel.bottomAnchor, constant: 20),
            idCardView.leadingAnchor.constraint(equalTo: informationVerificationLabel.leadingAnchor),
            idCardView.trailingAnchor.constraint(equalTo: informationVerificationLabel.trailingAnchor),
            idCardView.heightAnchor.constraint(equalToConstant: 50),
            
            driverView.topAnchor.constraint(equalTo: idCardView.bottomAnchor, constant: 10),
            driverView.leadingAnchor.constraint(equalTo: informationVerificationLabel.leadingAnchor),
            driverView.trailingAnchor.constraint(equalTo: informationVerificationLabel.trailingAnchor),
            driverView.heightAnchor.constraint(equalToConstant: 50),
            
            passportView.topAnchor.constraint(equalTo: driverView.bottomAnchor, constant: 10),
            passportView.leadingAnchor.constraint(equalTo: informationVerificationLabel.leadingAnchor),
            passportView.trailingAnchor.constraint(equalTo: informationVerificationLabel.trailingAnchor),
            passportView.heightAnchor.constraint(equalToConstant: 50)
            

        ])
    }
    
    @objc func handleHelp() {
        helperBottomRegistrationMenuLauncher.showImageSettings(in: view)
    }
}

extension VerificationRegistrationViewController: HelperBottomMenuLauncherDelegate {
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
        backItem.tintColor = .black
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
