//
//  DeactivatePasswordViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 23/6/23.
//

import UIKit

class DeactivatePasswordViewController: UIViewController {
    
    private var toolbar: UIToolbar!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let passwordLabel: UILabel  = {
        let label = CustomLabel(placeholder: "Confirm your password")
            return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Re-enter your password to complete your deactivation request."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    private let passwordTextField: UITextField = {
        let tf = InputTextField(placeholder: "Password", secureTextEntry: true)
        return tf
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = .systemRed
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleDeactivate), for: .touchUpInside)
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 14, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Deactivate", attributes: container)
        return button
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleDismiss))
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        view.addSubview(scrollView)
        
        scrollView.addSubviews(passwordLabel, passwordTextField, contentLabel)
        
        NSLayoutConstraint.activate([
            passwordLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            passwordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.becomeFirstResponder()
        
        // Create a toolbar
        toolbar = UIToolbar()
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithTransparentBackground()
        toolbar.standardAppearance = appearance
        toolbar.scrollEdgeAppearance = appearance
        toolbar.sizeToFit()

        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)

        let customButton = UIBarButtonItem(customView: nextButton)
        customButton.isEnabled = false

        toolbar.items = [flexibleSpace, customButton]

        passwordTextField.inputAccessoryView = toolbar
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func customButtonTapped() {
        // Perform the desired action when the button is tapped
        print("Custom button tapped!")
    }
    
    @objc func textDidChange() {
        guard let text = passwordTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            toolbar.items?.last?.isEnabled = false
            return
        }
        
        toolbar.items?.last?.isEnabled = true
    }
    
    @objc func handleDeactivate() {
        guard let password = passwordTextField.text, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        AuthService.reauthenticate(with: password) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                return
            } else {
                strongSelf.displayMEDestructiveAlert(withTitle: "Deactivate your account?", withMessage: "Your account will be deactivated.", withCancelButtonText: "Cancel", withDoneButtonText: "Yes, deactivate") {
                    
                    AuthService.deactivate { [weak self] error in
                        guard let strongSelf = self else { return }
                        if let _ = error {
                            strongSelf.displayAlert(withTitle: "Error", withMessage: "Oops, something went wrong. Please try again later.")
                        } else {

                            let controller = UserChangesViewController(change: .deactivate)
                            let navVC = UINavigationController(rootViewController: controller)
                            navVC.modalPresentationStyle = .fullScreen
                            strongSelf.present(navVC, animated: true) {
                                strongSelf.navigationController?.popToRootViewController(animated: true)
                            }
                        }
                    }
                }
            }
        }
    }
}

