//
//  PasswordRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit
import FirebaseAuth

class PasswordRegistrationViewController: UIViewController {
    
    private var email: String
  
    private var viewModel = PasswordRegistrationViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .none
        return scrollView
    }()
    
    private let emailTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.logInEmailPlaceholder, secureTextEntry: false, title: AppStrings.Opening.logInEmailPlaceholder)
        tf.isUserInteractionEnabled = false
        return tf
    }()
    
    private let passwordTextLabel: UILabel = {
        let label = PrimaryLabel(placeholder: AppStrings.Opening.registerPasswordTitle)
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.logInPasswordPlaceholder, secureTextEntry: true, title: AppStrings.Opening.logInPasswordPlaceholder)
        return tf
    }()
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = primaryColor
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule

        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 18, weight: .bold)
        config.attributedTitle = AttributedString(AppStrings.Opening.signUp, attributes: container)
        
        button.configuration = config
        button.addTarget(self, action: #selector(handleCreateAccount), for: .touchUpInside)
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configure()
        setUpTarget()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {

    }
    
    private func setUpTarget() {
        passwordTextField.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
    }
    
    private func configure() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        scrollView.addSubviews(emailTextField, passwordTextLabel, passwordTextField, createAccountButton)

        NSLayoutConstraint.activate([
            passwordTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            passwordTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            passwordTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: passwordTextLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: passwordTextLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: passwordTextLabel.trailingAnchor),
            
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTextLabel.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordTextLabel.trailingAnchor),

            createAccountButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40),
            createAccountButton.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            createAccountButton.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        emailTextField.text = email
    }
    
    @objc func didTapBack() {
        passwordTextField.resignFirstResponder()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func passwordDidChange() {
        let password = passwordTextField.text
        viewModel.password = password
        updateForm()
    }
    
    @objc func handleCreateAccount() {
        guard let password = passwordTextField.text else { return }
        guard password.count >= 8 else {
            displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.weakPassword)
            return
        }
        
        let credentials = AuthCredentials(email: email, password: password, phase: .category)
        guard let email = credentials.email, let password = credentials.password else { return }
        
        showProgressIndicator(in: view)
    
        AuthService.registerUser(withCredential: credentials) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.dismissProgressIndicator()
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                return
            }
            
            AuthService.logUserIn(withEmail: email, password: password) { [weak self] result in
                guard let strongSelf = self else { return }
                
                switch result {
                case .success(let authResult):
                    let uid = authResult.user.uid
                    UserService.fetchUser(withUid: uid) { [weak self] result in
                        guard let strongSelf = self else { return }
                        strongSelf.dismissProgressIndicator()
                        switch result {
                        case .success(let user):
                            #warning("m'he quedat aquí, mirar seguients VC per posar els setUserDefaults també i seguir endavant. un co pacabar això tornar a maintab controller solucionar els warnings que hi ha i probar que funciona.")
                            strongSelf.setUserDefaults(for: user)
                            let controller = CategoryViewController(user: user)
                            let nav = UINavigationController(rootViewController: controller)
                            nav.modalPresentationStyle = .fullScreen
                            strongSelf.present(nav, animated: true)
                        case .failure(let error):
                            strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                        }
                    }
                case .failure(let error):
                    strongSelf.dismissProgressIndicator()
                    strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
                }
            }
        }
    }
}

extension PasswordRegistrationViewController: FormViewModel {
    func updateForm() {
        createAccountButton.isEnabled = !viewModel.passwordIsEmpty
    }
}
