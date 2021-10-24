//
//  WelcomeViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/21.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let firstWelcomeText: UILabel = {
        let label = CustomLabel(placeholder: "Revolutionizing the health community.")
        return label
    }()
    
    private let secondWelcomeText: UILabel = {
        let label = CustomLabel(placeholder: "Your knowledge matters.")
        return label
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = UIColor(rgb: 0xEBEBEB)
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 18)
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.setDimensions(height: 1, width: 310)
        label.backgroundColor = UIColor(rgb: 0xEBEBEB)
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0x79CBBF)
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 18)
        button.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    //MARK: - Helpers
    func configureUI() {
        view.backgroundColor = .white
        
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black
        
        
        let stack = UIStackView(arrangedSubviews: [firstWelcomeText,secondWelcomeText])
        stack.axis = .vertical
        stack.spacing = 15
        
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        stack.anchor(left: view.safeAreaLayoutGuide.leftAnchor, paddingLeft: 30)
        stack.anchor(right: view.safeAreaLayoutGuide.leftAnchor, paddingRight: 20)
        
        let stackButtons = UIStackView(arrangedSubviews: [loginButton, separatorLabel, signUpButton])
        stackButtons.axis = .vertical
        stackButtons.spacing = 6
        
        view.addSubview(stackButtons)
        stackButtons.centerX(inView: view)
        stackButtons.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor, paddingBottom: 30)
        stackButtons.anchor(left: view.safeAreaLayoutGuide.leftAnchor, paddingLeft: 30)
        stackButtons.anchor(right: view.safeAreaLayoutGuide.leftAnchor, paddingRight: 20)
    }
    
    //MARK: - Handlers
    
    
    //MARK: - Actions
    @objc func loginButtonPressed() {
        print("did tap login")
        let controller = LoginViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func signupButtonPressed() {
        let controller = RegistrationViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
