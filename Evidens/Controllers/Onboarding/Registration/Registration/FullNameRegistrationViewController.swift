//
//  FullNameViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit
import MessageUI

class FullNameRegistrationViewController: UIViewController {
    
    private var user: User
    
    private var firstNameSelected: Bool = false
    private var lastNameSelected: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let nameTextLabel: UILabel = {
        let label = CustomLabel(placeholder: "What's your name?")
        return label
    }()
    
    private let instructionsNameLabel: UILabel = {
        let label = UILabel()
        label.text = "This will be displayed on your profile as your full name. You can always change that later."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let firstNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "First name")
        tf.tintColor = primaryColor
        tf.keyboardType = .default
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private let lastNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Last name")
        tf.tintColor = primaryColor
        tf.keyboardType = .default
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(systemName: "arrow.right", withConfiguration: UIImage.SymbolConfiguration(weight: .medium))?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    private lazy var helpButton: UIButton = {
        let button = UIButton()
        button.configuration = .gray()

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
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnViewTap()
        configureNavigationBar()
        configureUI()
        configureNotificationObservers()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Account Details"
        helpButton.menu = addMenuItems()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: helpButton)
    }
    
    private func configureNotificationObservers() {
        firstNameTextField.delegate = self
        firstNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        lastNameTextField.delegate = self
        lastNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        firstNameTextField.text = user.firstName
        lastNameTextField.text = user.lastName
        textDidChange()
        
        scrollView.addSubviews(nameTextLabel, instructionsNameLabel, firstNameTextField, lastNameTextField, nextButton)
        
        NSLayoutConstraint.activate([
            nameTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            nameTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            nameTextLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            instructionsNameLabel.topAnchor.constraint(equalTo: nameTextLabel.bottomAnchor, constant: 10),
            instructionsNameLabel.leadingAnchor.constraint(equalTo: nameTextLabel.leadingAnchor),
            instructionsNameLabel.trailingAnchor.constraint(equalTo: nameTextLabel.trailingAnchor),
            
            firstNameTextField.topAnchor.constraint(equalTo: instructionsNameLabel.bottomAnchor, constant: 10),
            firstNameTextField.leadingAnchor.constraint(equalTo: instructionsNameLabel.leadingAnchor),
            firstNameTextField.trailingAnchor.constraint(equalTo: instructionsNameLabel.trailingAnchor),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 5),
            lastNameTextField.leadingAnchor.constraint(equalTo: firstNameTextField.leadingAnchor),
            lastNameTextField.trailingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor),
            
            nextButton.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: lastNameTextField.trailingAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
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
    
    @objc func textDidChange() {
        if firstNameTextField.text != "" && lastNameTextField.text != "" {
            nextButton.isUserInteractionEnabled = true
            nextButton.configuration?.baseBackgroundColor = primaryColor
        } else {
            nextButton.isUserInteractionEnabled = false
            nextButton.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
        }
    }
    
    @objc func handleNext() {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text else { return }
        user.firstName = firstName
        user.lastName = lastName
        
        //let controller = ImageRegistrationViewController(user: user)
        let controller = InterestsViewController(user: user)
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FullNameRegistrationViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        firstNameSelected = textField == firstNameTextField ? true : false
        lastNameSelected = !firstNameSelected
        
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = primaryColor.cgColor
        textField.layer.borderWidth = 2.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        firstNameSelected = (textField == firstNameTextField) ? false : firstNameSelected
        lastNameSelected = (textField == lastNameTextField) ? false : lastNameSelected
        
        textField.backgroundColor = .tertiarySystemGroupedBackground
        textField.layer.borderColor = UIColor.systemBackground.cgColor
        textField.layer.borderWidth = 1.0
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                firstNameTextField.layer.borderColor = firstNameSelected ? primaryColor.cgColor : UIColor.systemBackground.cgColor
                lastNameTextField.layer.borderColor = lastNameSelected ? primaryColor.cgColor : UIColor.systemBackground.cgColor
            }
        }
    }
}

extension FullNameRegistrationViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if let _ = error {
            controller.dismiss(animated: true)
        }
        
        controller.dismiss(animated: true)
    }
}

