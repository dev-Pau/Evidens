//
//  EmailRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 20/12/21.
//

import UIKit
import Firebase

class WelcomeRegistrationViewController: UIViewController {
    
    //MARK: - Properties
    
    public var firstName: String = ""
    
    private let infoUserLabel: UILabel = {
        let label = CustomLabel(placeholder: "Welcome to Evidens")
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Regular", size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private let backToLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Understood", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0x79CBBF)
        button.setHeight(50)
        button.isEnabled = true
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 16)
        button.addTarget(self, action: #selector(backToLoginButtonPressed), for: .touchUpInside)
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
        
        instructionsLabel.text = "\(firstName), thanks for signing in to Evidens. In order to start using your Evidens account, we have sent you an email with some instructions to verify your identity."
        
        let stack = UIStackView(arrangedSubviews: [infoUserLabel, instructionsLabel, backToLoginButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        stack.anchor(left: view.safeAreaLayoutGuide.leftAnchor, paddingLeft: 30)
        stack.anchor(right: view.safeAreaLayoutGuide.leftAnchor, paddingRight: 20)
    }
    
    //MARK: - Actions
    
    @objc func backToLoginButtonPressed() {
        let controller = WelcomeViewController()
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: false, completion: nil)
    }
}
