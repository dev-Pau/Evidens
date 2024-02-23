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
        let label = PrimaryLabel(placeholder: AppStrings.Settings.changeEmail)
            return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = primaryGray
        label.numberOfLines = 0
        label.text = AppStrings.Settings.changeEmailContent
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        return label
    }()

    private let emailTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Settings.emailPlaceholder, secureTextEntry: false, title: AppStrings.Opening.logInEmailPlaceholder)
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
        container.font = UIFont.addFont(size: 17, scaleStyle: .title2, weight: .semibold, scales: false)
        button.isEnabled = false
        button.configuration?.attributedTitle = AttributedString(AppStrings.Miscellaneous.next, attributes: container)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    private func configureNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .label
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
        
        emailTextField.autocapitalizationType = .none
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
        
        let email = text.trimmingCharacters(in: .whitespaces)
        
        AuthService.changeEmail(to: email) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error = error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.dismiss(animated: true)
                }

            } else {
                strongSelf.emailTextField.resignFirstResponder()
                let controller = UserChangesViewController(change: .email)
                strongSelf.navigationItem.backBarButtonItem = nil
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}

