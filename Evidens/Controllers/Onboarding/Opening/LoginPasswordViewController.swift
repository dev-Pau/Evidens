//
//  LoginPasswordViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/7/23.
//

import UIKit

class LoginPasswordViewController: UIViewController {
    
    //MARK: - Properties
    
    var viewModel = LoginPasswordViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .none
        return scrollView
    }()
    
    private let loginEmailTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.logInEmailPlaceholder, secureTextEntry: false, title: AppStrings.Opening.logInEmailPlaceholder)
        tf.isUserInteractionEnabled = false
        tf.textColor = .label
        return tf
    }()
    
    private let loginPasswordLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Opening.logInPasswordTitle)
        return label
    }()
    
    private let loginPasswordTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.logInPasswordPlaceholder, secureTextEntry: true, title: AppStrings.Opening.logInPasswordPlaceholder)
        return tf
    }()
    
    private lazy var logInButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.configuration?.baseBackgroundColor = primaryColor
        button.configuration?.baseForegroundColor = .white
        button.configuration?.cornerStyle = .capsule
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 17, scaleStyle: .body, weight: .semibold, scales: false)
        button.isEnabled = false
        button.configuration?.attributedTitle = AttributedString(AppStrings.Opening.logIn, attributes: container)
        return button
    }()
    
    private let email: String

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loginPasswordTextField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        loginPasswordTextField.resignFirstResponder()
    }
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        addNavigationBarLogo(withTintColor: primaryColor)
    }
    
    private func configure() {
        loginEmailTextField.text = email
        
        view.addSubviews(scrollView)
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        
        let stack = UIStackView(arrangedSubviews: [loginPasswordLabel, loginEmailTextField])
        stack.axis = .vertical
        stack.spacing = 40
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubviews(stack, loginPasswordTextField, logInButton)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            loginPasswordTextField.topAnchor.constraint(equalTo: stack.bottomAnchor, constant: 20),
            loginPasswordTextField.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            loginPasswordTextField.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
            
            logInButton.topAnchor.constraint(equalTo: loginPasswordTextField.bottomAnchor, constant: 40),
            logInButton.leadingAnchor.constraint(equalTo: loginPasswordTextField.leadingAnchor),
            logInButton.trailingAnchor.constraint(equalTo: loginPasswordTextField.trailingAnchor),
            logInButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        loginPasswordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    //MARK: - Actions
    
    @objc func handleLogin() {
        guard let _ = viewModel.password else { return }
        loginPasswordTextField.resignFirstResponder()
        
        viewModel.logUserIn(withEmail: email, presentingIn: self) { [weak self] result in
            guard let strongSelf = self else { return }
            switch result {
            case .success(_):
                let controller = ContainerViewController()
                controller.modalPresentationStyle = .fullScreen
                strongSelf.present(controller, animated: false)
            case .failure(let error):
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content) { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.loginPasswordTextField.becomeFirstResponder()
                }
            }
        }
    }
    
    @objc func textDidChange() {
        viewModel.set(password: loginPasswordTextField.text)
        logInButton.isEnabled = !viewModel.isPasswordEmpty()
    }
}
