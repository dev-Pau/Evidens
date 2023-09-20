//
//  LoginEmailViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

protocol LoginEmailViewControllerDelegate: AnyObject {
    func didTapForgotPassword()
}

class LoginEmailViewController: UIViewController {
    
    //MARK: - Properties
    
    private var viewModel = LoginEmailViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .none
        return scrollView
    }()
    
    private let loginEmailLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Opening.logInEmailTitle)
        return label
    }()
    
    private let loginEmailTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.logInEmailPlaceholder, secureTextEntry: false, title: AppStrings.Opening.logInEmailPlaceholder)
        tf.keyboardType = .emailAddress
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
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = .label
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .regular)
        config.contentInsets = NSDirectionalEdgeInsets.zero
        config.attributedTitle = AttributedString(AppStrings.Opening.forgotPassword, attributes: container)
        config.cornerStyle = .capsule
        button.configuration = config
        button.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    weak var delegate: LoginEmailViewControllerDelegate?
    private var nextToolbarButton: UIBarButtonItem!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        configureNavigationBar()
        configureNotificationsObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginEmailTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loginEmailTextField.resignFirstResponder()
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    func configure() {
        view.addSubview(scrollView)
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
      
        let stack = UIStackView(arrangedSubviews: [loginEmailLabel, loginEmailTextField])
        stack.axis = .vertical
        stack.spacing = 40
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
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
        let forgotToolbarButton = UIBarButtonItem(customView: forgotPasswordButton)
        
        nextToolbarButton = UIBarButtonItem(customView: nextButton)
        toolbar.items = [forgotToolbarButton, flexibleSpace, nextToolbarButton]
        loginEmailTextField.inputAccessoryView = toolbar
        nextToolbarButton.isEnabled = false
    }
    
    func configureNotificationsObservers() {
        loginEmailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    //MARK: - Actions
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        viewModel.set(email: sender.text)
        nextToolbarButton.isEnabled = !viewModel.isEmailEmpty()
    }
    
    @objc func forgotPasswordButtonPressed() {
        navigationController?.popViewController(animated: true)
        delegate?.didTapForgotPassword()
    }
    
    @objc func didTapBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleLogin() {
        guard let email = viewModel.email else { return }
        loginEmailTextField.resignFirstResponder()
        showProgressIndicator(in: view)
        
        AuthService.fetchProviders(withEmail: email) { [weak self] result in
            guard let strongSelf = self else { return }
            
            strongSelf.dismissProgressIndicator()
            
            switch result {
            case .success(let provider):
                print(provider)
                switch provider {
                case .password:
                    let controller = LoginPasswordViewController(email: email)
                    strongSelf.navigationController?.pushViewController(controller, animated: true)
                    
                case .google:
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: provider.login)
                case .apple:
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: provider.login)
                case .undefined:
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                }
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.loginEmailTextField.becomeFirstResponder()
                }
            }
        }
    }
}
