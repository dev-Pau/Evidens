//
//  VerifyPasswordViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 21/6/23.
//

import UIKit

class ConfirmPasswordViewController: UIViewController {
    
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
        label.text = "Re-enter your password to continue."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    private let passwordTextField: UITextField = {
        let tf = InputTextField(placeholder: "Password", secureTextEntry: true, title: "Password")
        return tf
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = .label
        button.configuration?.baseForegroundColor = .systemBackground
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleAuth), for: .touchUpInside)
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 17, weight: .semibold)
        button.isEnabled = false
        button.configuration?.attributedTitle = AttributedString("Next", attributes: container)
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
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        
        scrollView.addSubviews(passwordLabel, passwordTextField, contentLabel, nextButton)
        
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
            
            nextButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 30),
            nextButton.leadingAnchor.constraint(equalTo: passwordLabel.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: passwordLabel.trailingAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func textDidChange() {
        guard let text = passwordTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            nextButton.isEnabled = false
            return
        }
        
        nextButton.isEnabled = true
    }
    
    @objc func handleAuth() {
        guard let password = passwordTextField.text, !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        
        AuthService.reauthenticate(with: password) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                return
            } else {
                let controller = AddEmailViewController()
                strongSelf.navigationItem.backBarButtonItem = nil
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
