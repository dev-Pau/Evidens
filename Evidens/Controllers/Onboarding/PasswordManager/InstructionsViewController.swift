//
//  InstructionsViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/10/21.
//

import UIKit

class InstructionsViewController: UIViewController {
    
    //MARK: - Properties
    
    private let checkLabel: UILabel = {
        let label = CustomLabel(placeholder: "Check your email")
        return label
    }()
    
    private let instructionsLabel: UILabel = {
        let label = UILabel()
        label.text = "We have sent a password recover instructions to your email."
        label.font = UIFont(name: "Raleway-Regular", size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.setDimensions(height: 1, width: 200)
        label.backgroundColor = UIColor(rgb: 0xEBEBEB)
        return label
    }()
    
    private let didNotReceiveLabel: UILabel = {
        let label = UILabel()
        label.text = "Did not receive the email? Check your spam filter, or"
        label.font = UIFont(name: "Raleway-Regular", size: 13)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private let tryAnotherEmailButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("try another email address", for: .normal)
        button.setTitleColor(UIColor(rgb: 0x79CBBF), for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 16)
        button.addTarget(self, action: #selector(tryAnotherEmailButtonPressed), for: .touchUpInside)
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
        
        let stack = UIStackView(arrangedSubviews: [checkLabel, instructionsLabel, separatorLabel, didNotReceiveLabel, tryAnotherEmailButton])
        stack.axis = .vertical
        stack.spacing = 5
        
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        stack.anchor(left: view.safeAreaLayoutGuide.leftAnchor, paddingLeft: 30)
        stack.anchor(right: view.safeAreaLayoutGuide.leftAnchor, paddingRight: 20)
    }
    
    //MARK: Actions
    
    @objc func tryAnotherEmailButtonPressed() {
        let controller = ResetPasswordViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
}
