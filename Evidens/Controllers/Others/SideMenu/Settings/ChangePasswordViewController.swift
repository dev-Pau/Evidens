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
    
    private let kindSeparator: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = K.Colors.separatorColor
        return view
    }()
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 13.0, scaleStyle: .title1, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.numberOfLines = 0
        return label
    }()
    
    private let currentPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .semibold)
        label.text = AppStrings.User.Changes.currentPassword
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var currentPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .never
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        tf.tintColor = K.Colors.primaryColor
        tf.textColor = K.Colors.primaryColor
        return tf
    }()
    
    private let newPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .semibold)
        label.text = AppStrings.User.Changes.newPassword
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var newPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .never
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        tf.tintColor = K.Colors.primaryColor
        tf.textColor = K.Colors.primaryColor
        tf.placeholder = AppStrings.User.Changes.passwordRules
        return tf
    }()
    
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .semibold)
        label.text = AppStrings.User.Changes.confirmPassword
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var confirmPasswordTextField: UITextField = {
        let tf = UITextField()
        tf.font = UIFont.addFont(size: 15.0, scaleStyle: .title1, weight: .regular)
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.clearButtonMode = .never
        tf.isSecureTextEntry = true
        tf.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
        tf.tintColor = K.Colors.primaryColor
        tf.textColor = K.Colors.primaryColor
        tf.placeholder = AppStrings.User.Changes.passwordRules
        return tf
    }()
    
    private var passwordConditionTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.primaryColor]
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.contentInset = .zero
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = .zero
        return tv
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
        title = AppStrings.Settings.accountPasswordTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: AppStrings.Global.done, style: .done, target: self, action: #selector(handleChangePassword))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .onDrag
        view.addSubview(scrollView)
        
        scrollView.addSubviews(kindLabel, kindSeparator, passwordConditionTextView, currentPasswordLabel, currentPasswordTextField, newPasswordLabel, newPasswordTextField, confirmPasswordLabel, confirmPasswordTextField)
        
        confirmPasswordLabel.setContentHuggingPriority(.required, for: .horizontal)
        confirmPasswordLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            kindLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: K.Paddings.Settings.verticalPadding),
            kindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: K.Paddings.Settings.horizontalPadding),
            kindLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -K.Paddings.Settings.horizontalPadding),
            
            kindSeparator.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 10),
            kindSeparator.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            kindSeparator.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            kindSeparator.heightAnchor.constraint(equalToConstant: 0.4),
            
            currentPasswordLabel.topAnchor.constraint(equalTo: kindSeparator.bottomAnchor, constant: 30),
            currentPasswordLabel.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            
            newPasswordLabel.topAnchor.constraint(equalTo: currentPasswordLabel.bottomAnchor, constant: 30),
            newPasswordLabel.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            
            confirmPasswordLabel.topAnchor.constraint(equalTo: newPasswordLabel.bottomAnchor, constant: 30),
            confirmPasswordLabel.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            
            currentPasswordTextField.centerYAnchor.constraint(equalTo: currentPasswordLabel.centerYAnchor),
            currentPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordLabel.trailingAnchor, constant: 20),
            currentPasswordTextField.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
            
            newPasswordTextField.centerYAnchor.constraint(equalTo: newPasswordLabel.centerYAnchor),
            newPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordLabel.trailingAnchor, constant: 20),
            newPasswordTextField.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
            
            confirmPasswordTextField.centerYAnchor.constraint(equalTo: confirmPasswordLabel.centerYAnchor),
            confirmPasswordTextField.leadingAnchor.constraint(equalTo: confirmPasswordLabel.trailingAnchor, constant: 20),
            confirmPasswordTextField.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
            
            passwordConditionTextView.topAnchor.constraint(equalTo: confirmPasswordLabel.bottomAnchor, constant: 30),
            passwordConditionTextView.leadingAnchor.constraint(equalTo: kindLabel.leadingAnchor),
            passwordConditionTextView.trailingAnchor.constraint(equalTo: kindLabel.trailingAnchor),
        ])
        
        let font = UIFont.addFont(size: 13, scaleStyle: .title2, weight: .regular)
        kindLabel.text = AppStrings.Settings.accountPasswordContent
        let passwordString = NSMutableAttributedString(string: AppStrings.User.Changes.changesRules, attributes: [.font: font, .foregroundColor: K.Colors.primaryGray])
      
        passwordConditionTextView.attributedText = passwordString
    }
    
    private func updateForm() {
        navigationItem.rightBarButtonItem?.isEnabled = viewModel.formIsValid
        navigationItem.rightBarButtonItem?.tintColor = K.Colors.primaryColor
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
        guard let password = viewModel.currentPassword, let newPassword = viewModel.newPassword else { return }
        
        guard password != newPassword else {
            
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.User.Changes.equal)
            return
        }
        guard viewModel.newPasswordMatch else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.User.Changes.missmatch)
            return
        }
        
        guard viewModel.newPasswordMinLength else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.User.Changes.passLength)
            return
        }
        
        showProgressIndicator(in: view)
        
        currentPasswordTextField.resignFirstResponder()
        newPasswordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
        
        AuthService.providerKind { [weak self] provider in
            guard let strongSelf = self else { return }
            guard provider == .password else {
                strongSelf.dismissProgressIndicator()
                strongSelf.displayAlert(withTitle: provider.title, withMessage: provider.content)
                return
            }
            
            AuthService.reauthenticate(with: password) { [weak self] error in
                guard let strongSelf = self else { return }
                if let error = error {
                    strongSelf.dismissProgressIndicator()
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    AuthService.changePassword(newPassword) { [weak self] error in
                        guard let strongSelf = self else { return }
                        strongSelf.dismissProgressIndicator()
                        
                        if let error = error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        } else {
                            
                            let controller = UserChangesViewController(change: .password)
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
