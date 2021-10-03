//
//  ResetPasswordViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/10/21.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    
    //MARK: - Properties
    private let resetPassword: UILabel = {
        let label = CustomLabel(placeholder: "Reset your password")
        return label
    }()
    
    private let instructionsPassword: UILabel = {
        let label = UILabel()
        label.text = "Enter the email associated with your account and we'll send an email with instructions to reset your password."
        label.font = .systemFont(ofSize: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0x79CBBF)
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(UIColor(rgb: 0x79CBBF), for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        
    }
    
    //MARK: Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        
        let stack = UIStackView(arrangedSubviews: [resetPassword, instructionsPassword, emailTextField, resetButton, cancelButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        stack.anchor(left: view.safeAreaLayoutGuide.leftAnchor, paddingLeft: 30)
        stack.anchor(right: view.safeAreaLayoutGuide.leftAnchor, paddingRight: 20)
    }
    
    //MARK:  - Actions
    @objc func cancelButtonPressed() {
        let controller = LoginViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func resetButtonPressed() {
     let controller = InstructionsViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
