//
//  LoginViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit

class LoginViewController: UIViewController {
    
    //MARK: - Properties

    private let evidensTextField: UILabel = {
        let label = CustomLabel(placeholder: "Welcome back")
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0x79CBBF)
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Trouble logging in?", for: .normal)
        button.setTitleColor(UIColor(rgb: 0x79CBBF), for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        return button
    }()

    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.setTitleColor(UIColor(rgb: 0x79CBBF), for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.attributedTitle(buttonInfo: "Don't have an account?", buttonContent: "Create account")
        return button
    }()
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpDelegates()
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black

        let stack = UIStackView(arrangedSubviews: [evidensTextField, emailTextField, passwordTextField, loginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        stack.anchor(left: view.safeAreaLayoutGuide.leftAnchor, paddingLeft: 20)
        stack.anchor(right: view.safeAreaLayoutGuide.leftAnchor, paddingRight: 20)
        
        view.addSubview(forgotPasswordButton)
        forgotPasswordButton.anchor(top: loginButton.bottomAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 15, paddingLeft: 20)
        
        view.addSubview(signUpButton)
        signUpButton.centerX(inView: view)
        signUpButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
        
    }
    
    func setUpDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    //MARK: - Actions
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @objc func forgotPasswordButtonPressed() {
        let controller = ResetPasswordViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
            textField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            textField.borderStyle = .roundedRect
            textField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
            textField.layer.borderWidth = 2.0
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            textField.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            textField.layer.borderColor = UIColor.white.cgColor
            textField.layer.borderWidth = 1.0
            
            //Secure text entry true by default when user ends editing
            if textField == passwordTextField {
                textField.isSecureTextEntry = true
            }
    }
}
