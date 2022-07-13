//
//  PasswordRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit

class PasswordRegistrationViewController: UIViewController {
    
    private var email: String
    private let imageIcon = UIImageView()
    private var iconClick = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let passwordTextLabel: UILabel = {
        let label = CustomLabel(placeholder: "Create a password")
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.tintColor = primaryColor
        return tf
    }()
    
    private let repeatPasswordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Repeat password")
        tf.tintColor = primaryColor
        return tf
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        setUpDelegates()
        configureEye()
    }
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Create account"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBack))
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func setUpDelegates() {
        passwordTextField.delegate = self
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(passwordTextLabel, passwordTextField)
        
        NSLayoutConstraint.activate([
            passwordTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            passwordTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            passwordTextLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordTextLabel.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTextLabel.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordTextLabel.trailingAnchor),
        ])
    }
    
    private func configureEye() {
        imageIcon.image = UIImage(systemName: "eye.fill")
        imageIcon.tintColor = primaryColor
        
        let contentView = UIView()
        contentView.addSubview(imageIcon)
        
        contentView.frame = CGRect(x: 0, y: 0, width: (UIImage(systemName: "eye.fill")?.size.width)!, height: (UIImage(systemName: "eye.fill")?.size.height)!)
        
        imageIcon.frame = CGRect(x: -10, y: -2.5, width: (UIImage(systemName: "eye.fill")?.size.width)! + 3, height: (UIImage(systemName: "eye.fill")?.size.height)! + 3)
        
        passwordTextField.rightView = contentView
        passwordTextField.rightViewMode = .always
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageIcon.isUserInteractionEnabled = true
        imageIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        tappedImage.tintColor = primaryColor
        if iconClick {
            iconClick = false
            tappedImage.image = UIImage(systemName: "eye.slash.fill")
            tappedImage.tintColor = primaryColor
            passwordTextField.isSecureTextEntry = false
        } else {
            iconClick = true
            tappedImage.image = UIImage(systemName: "eye.fill")
            passwordTextField.isSecureTextEntry = true
        }
    }
}

extension PasswordRegistrationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .white
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = primaryColor.cgColor
        textField.layer.borderWidth = 2.0

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = lightColor
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1.0
        //Secure text entry true by default when user ends editing
        if textField == passwordTextField {
            //textField.isSecureTextEntry = true
        }
    }
}
