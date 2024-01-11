//
//  ConfirmPasswordViewController.swift
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
        let label = PrimaryLabel(placeholder: AppStrings.Settings.confirmPassword)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = AppStrings.Settings.copy
        label.font = UIFont.addFont(size: 15, scaleStyle: .title2, weight: .regular)
        return label
    }()

    private let passwordTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.logInPasswordPlaceholder, secureTextEntry: true, title: AppStrings.Opening.logInPasswordPlaceholder)
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
    
    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))

        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance
        
        appearance.shadowImage = nil
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: AppStrings.Global.cancel, style: .plain, target: self, action: #selector(handleDismiss))
        navigationItem.leftBarButtonItem?.tintColor = .label
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
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                return
            } else {
                let controller = AddEmailViewController()
                strongSelf.navigationItem.backBarButtonItem = nil
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
}
