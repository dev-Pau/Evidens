//
//  ResetPasswordViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/10/21.
//

import UIKit
import JGProgressHUD

protocol ResetPasswordViewControllerDelegate: AnyObject {
    func controllerDidSendResetPassword(_ controller: ResetPasswordViewController)
}

class ResetPasswordViewController: UIViewController {
    
    //MARK: - Properties

    private let progressIndicator = JGProgressHUD()
    weak var delegate: ResetPasswordViewControllerDelegate?
    private var nextToolbarButton: UIBarButtonItem!
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .none
        return scrollView
    }()
    
    private let resetPasswordLabel: UILabel = {
        let label = CustomLabel(placeholder: AppStrings.Opening.passwordTitle)
        return label
    }()
    
    private let contentLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.text = AppStrings.Opening.passwordContent
        label.font = .systemFont(ofSize: 15, weight: .regular)
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.logInEmailPlaceholder, secureTextEntry: false, title: AppStrings.Opening.logInEmailPlaceholder)
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = primaryColor
        config.baseForegroundColor = .white
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        
        config.attributedTitle = AttributedString(AppStrings.Miscellaneous.next, attributes: container)
        config.cornerStyle = .capsule
        button.configuration = config
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: Helpers
    
    func configure() {
        view.backgroundColor = .systemBackground
        
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        scrollView.addSubviews(resetPasswordLabel, contentLabel, emailTextField)
        
        NSLayoutConstraint.activate([
            resetPasswordLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            resetPasswordLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resetPasswordLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            contentLabel.topAnchor.constraint(equalTo: resetPasswordLabel.bottomAnchor, constant: 10),
            contentLabel.leadingAnchor.constraint(equalTo: resetPasswordLabel.leadingAnchor),
            contentLabel.trailingAnchor.constraint(equalTo: resetPasswordLabel.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 20),
            emailTextField.leadingAnchor.constraint(equalTo: resetPasswordLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: resetPasswordLabel.trailingAnchor),
        ])
        
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        toolbar.standardAppearance = appearance
        toolbar.scrollEdgeAppearance = appearance
        toolbar.sizeToFit()
        
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        nextToolbarButton = UIBarButtonItem(customView: nextButton)
        toolbar.items = [flexibleSpace, nextToolbarButton]
        emailTextField.inputAccessoryView = toolbar
        nextToolbarButton.isEnabled = false
        
        emailTextField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
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
    }
    
    //MARK:  - Actions

    @objc func textDidChange(_ textField: UITextField) {
        guard let email = textField.text, !email.trimmingCharacters(in: .whitespaces).isEmpty else {
            nextToolbarButton.isEnabled = false
            return
        }
        nextToolbarButton.isEnabled = true
    }

    @objc func handleNext() {
        guard let email = emailTextField.text, !email.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        progressIndicator.show(in: view)
        AuthService.fetchProviders(withEmail: email) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(let provider):
                print(provider)
                switch provider {
                case .password, .undefined:
                    AuthService.resetPassword(withEmail: email) { [weak self] error in
                        guard let strongSelf = self else { return }
                        strongSelf.progressIndicator.dismiss(animated: true)
                        if let error = error {
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                            return
                        } else {
                            strongSelf.handleDismiss()
                            strongSelf.delegate?.controllerDidSendResetPassword(strongSelf)
                        }
                    }
                case .google:
                    strongSelf.progressIndicator.dismiss(animated: true)
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: provider.content)
                case .apple:
                    strongSelf.progressIndicator.dismiss(animated: true)
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: provider.content)
                }
            case .failure(let error):
                strongSelf.progressIndicator.dismiss(animated: true)
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            }
        }
    }
    
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
