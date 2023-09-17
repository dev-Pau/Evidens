//
//  ChangePasswordViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/6/23.
//

import UIKit

class ChangePasswordViewController: UIViewController {
    
    private var viewModel = ChangePasswordViewModel()
    private let passwordDetailsMenu = ContextMenu(display: .password)
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let kindLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 13, weight: .regular)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let currentPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = AppStrings.User.Changes.currentPassword
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
        label.text = AppStrings.User.Changes.newPassword
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
        tf.placeholder = AppStrings.User.Changes.passwordRules
        return tf
    }()
    
    private let confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.text = AppStrings.User.Changes.confirmPassword
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
        tf.placeholder = AppStrings.User.Changes.passwordRules
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
    
    
    private var passwordConditionTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
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
        scrollView.addSubviews(kindLabel, passwordConditionTextView, currentPasswordLabel, currentPasswordTextField, passwordSeparatorView, newPasswordLabel, newPasswordTextField, newPasswordSeparatorView, confirmPasswordLabel, confirmPasswordTextField, confirmPasswordSeparatorView)
        
        currentPasswordLabel.sizeToFit()
        currentPasswordLabel.setContentHuggingPriority(.required, for: .horizontal)
        currentPasswordLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        NSLayoutConstraint.activate([
            kindLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            kindLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            kindLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10),
            
            passwordConditionTextView.topAnchor.constraint(equalTo: kindLabel.bottomAnchor, constant: 10),
            passwordConditionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            passwordConditionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            currentPasswordLabel.topAnchor.constraint(equalTo: passwordConditionTextView.bottomAnchor, constant: 20),
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
        
        kindLabel.text = AppStrings.Settings.accountPasswordContent
        let passwordString = NSMutableAttributedString(string: AppStrings.User.Changes.changesRules + " " + AppStrings.Content.Empty.learn, attributes: [.font: UIFont.systemFont(ofSize: 13, weight: .regular), .foregroundColor: UIColor.secondaryLabel])
        passwordString.addAttributes([.foregroundColor: primaryColor, .link: NSAttributedString.Key("presentCommunityInformation")], range: (passwordString.string as NSString).range(of: AppStrings.Content.Empty.learn))
    
        passwordConditionTextView.attributedText = passwordString
        passwordConditionTextView.delegate = self
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
        guard let password = viewModel.currentPassword, let newPassword = viewModel.newPassword else { return }
        guard viewModel.newPasswordMatch else {
            let popUp = PopUpBanner(title: AppStrings.User.Changes.missmatch, image: AppStrings.Icons.xmarkCircleFill, popUpKind: .destructive)
            popUp.showTopPopup(inView: view)
            HapticsManager.shared.triggerErrorHaptic()
            return
        }
        
        guard viewModel.newPasswordMinLength else {
            let popUp = PopUpBanner(title: AppStrings.User.Changes.passLength, image: AppStrings.Icons.xmarkCircleFill, popUpKind: .destructive)
            popUp.showTopPopup(inView: view)
            HapticsManager.shared.triggerErrorHaptic()
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
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                } else {
                    AuthService.changePassword(newPassword) { [weak self] error in
                        guard let strongSelf = self else { return }
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

extension ChangePasswordViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "presentCommunityInformation" {
            currentPasswordTextField.resignFirstResponder()
            newPasswordTextField.resignFirstResponder()
            confirmPasswordTextField.resignFirstResponder()
            passwordDetailsMenu.showImageSettings(in: view)
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}
