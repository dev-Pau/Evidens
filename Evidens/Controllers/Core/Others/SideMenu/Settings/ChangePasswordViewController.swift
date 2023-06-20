//
//  ChangePasswordViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    private var viewModel = ChangePasswordViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let currentPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Current Password"
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var currentPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .never
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        tf.tintColor = primaryColor
        tf.textColor = primaryColor
        return tf
    }()
    
    private let newPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "New Password"
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .never
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        tf.tintColor = primaryColor
        tf.textColor = primaryColor
        tf.placeholder = "At least 8 characters"
        return tf
    }()
    
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = "Confirm Password"
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.font = .systemFont(ofSize: 15, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .never
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        tf.tintColor = primaryColor
        tf.textColor = primaryColor
        tf.placeholder = "At least 8 characters"
        return tf
    }()
    
    private let passwordSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let newPasswordSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    private let confirmPasswordSeparatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = separatorColor
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentPasswordTextField.becomeFirstResponder()
    }
    
    private func configureNavigationBar() {
        title = "Change Password"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(handleChangePassword))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        scrollView.addSubviews(currentPasswordLabel, currentPasswordTextField, passwordSeparatorView, newPasswordLabel, newPasswordTextField, newPasswordSeparatorView, confirmPasswordLabel, confirmPasswordTextField, confirmPasswordSeparatorView)
        
        currentPasswordLabel.sizeToFit()
        currentPasswordLabel.setContentHuggingPriority(.required, for: .horizontal)
        currentPasswordLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            currentPasswordLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            currentPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            currentPasswordLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            currentPasswordTextField.topAnchor.constraint(equalTo: currentPasswordLabel.topAnchor),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: currentPasswordLabel.trailingAnchor, constant: 10),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            passwordSeparatorView.topAnchor.constraint(equalTo: currentPasswordLabel.bottomAnchor, constant: 10),
            passwordSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            passwordSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            passwordSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            newPasswordLabel.topAnchor.constraint(equalTo: passwordSeparatorView.bottomAnchor, constant: 10),
            newPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            newPasswordLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            newPasswordTextField.topAnchor.constraint(equalTo: newPasswordLabel.topAnchor),
            newPasswordTextField.leadingAnchor.constraint(equalTo: currentPasswordLabel.trailingAnchor, constant: 10),
            newPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            newPasswordSeparatorView.topAnchor.constraint(equalTo: newPasswordLabel.bottomAnchor, constant: 10),
            newPasswordSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            newPasswordSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            newPasswordSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            confirmPasswordLabel.topAnchor.constraint(equalTo: newPasswordSeparatorView.bottomAnchor, constant: 10),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            confirmPasswordLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            confirmPasswordTextField.topAnchor.constraint(equalTo: confirmPasswordLabel.topAnchor),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: currentPasswordLabel.trailingAnchor, constant: 10),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            confirmPasswordSeparatorView.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 10),
            confirmPasswordSeparatorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            confirmPasswordSeparatorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            confirmPasswordSeparatorView.heightAnchor.constraint(equalToConstant: 0.4),
        ])
    }
    
    private func updateForm() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.formIsValid
    }
    
    @objc func textDidChange(_ textField: UITextField) {
        if textField == currentPasswordTextField {
            viewModel.currentPassword = textField.text?.trimmingCharacters(in: .whitespaces)
        } else if textField == newPasswordTextField {
            viewModel.newPassword = textField.text?.trimmingCharacters(in: .whitespaces)
        } else {
            viewModel.confirmPassword = textField.text?.trimmingCharacters(in: .whitespaces)
        }
        
        updateForm()
    }
    
    @objc func handleChangePassword() {
        guard let password = viewModel.newPassword else { return }
        guard viewModel.newPasswordMatch else {
            let popUp = METopPopupView(title: "The two given passwords do not match", image: AppStrings.Icons.xmarkCircleFill, popUpType: .destructive)
            popUp.showTopPopup(inView: view)
            return
        }
        
        guard viewModel.newPasswordMinLength else {
            let popUp = METopPopupView(title: "Your password needs to be at least 8 characters. Please enter a longer one", image: AppStrings.Icons.xmarkCircleFill, popUpType: .destructive)
            popUp.showTopPopup(inView: view)
            return
        }
        
        AuthService.providerKind { [weak self] provider in
            guard let strongSelf = self else { return }
            guard provider == .password else {
                strongSelf.displayAlert(withTitle: provider.title, withMessage: provider.content)
                return
            }
            
            AuthService.reauthenticate(with: password) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error = error {
                    strongSelf.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                    return
                }
                
                AuthService.changePassword(password) { error in
                    if let error = error {
                        strongSelf.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                        return
                    }
                    
                    let popUp = METopPopupView(title: "Your password has been successfully changed", image: AppStrings.Icons.checkmarkCircleFill, popUpType: .regular)
                    popUp.showTopPopup(inView: strongSelf.view)
                    strongSelf.navigationController?.popViewController(animated: true)
                    
                }
            }
        }
    }
}
