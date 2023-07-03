//
//  AddEmailViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 22/6/23.
//

import UIKit

class AddEmailViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let emailLabel: UILabel  = {
        let label = CustomLabel(placeholder: "Change your email")
            return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = "Enter the email address you'd like to associate with your account. Your email is not displayed in your public profile."
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()

    private let emailTextField: UITextField = {
        let tf = InputTextField(placeholder: "Email address", secureTextEntry: false, title: "Email")
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
        
        scrollView.addSubviews(emailLabel, emailTextField, contentLabel, nextButton)
        
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            emailLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            nextButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            nextButton.leadingAnchor.constraint(equalTo: emailLabel.leadingAnchor),
            nextButton.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            nextButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
    
    @objc func textDidChange() {
        guard let text = emailTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty, text.emailIsValid else {
            nextButton.isEnabled = false
            return
        }
        
        nextButton.isEnabled = true
    }
    
    @objc func handleAuth() {
        guard let text = emailTextField.text, !text.trimmingCharacters(in: .whitespaces).isEmpty, text.emailIsValid else { return }
        AuthService.changeEmail(to: text) { [weak self] error in
            guard let strongSelf = self else { return }
            if let _ = error {
                strongSelf.displayAlert(withTitle: "Error", withMessage: "Oops, something went wrong. Please try again later.")
                strongSelf.dismiss(animated: true)
            } else {
                let controller = UserChangesViewController(change: .email)
                strongSelf.navigationItem.backBarButtonItem = nil
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

