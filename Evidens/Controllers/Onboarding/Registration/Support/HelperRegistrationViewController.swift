//
//  HelperRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 16/7/22.
//

import UIKit

protocol HelperRegistrationViewControllerDelegate: AnyObject {
    func didTapContactSupport()
    func didTapLogout()
}

class HelperRegistrationViewController: UIViewController {
    
    weak var delegate: HelperRegistrationViewControllerDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "We're here to help"
        label.font = .systemFont(ofSize: 19, weight: .semibold)
        label.textColor = blackColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Our support team is here to help you. Contact us at support@myevidens.com if you need any assistance during the registration process."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = blackColor
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    private lazy var contactButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Contact support", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor
        button.layer.cornerRadius = 18
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleContact), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = " OR "
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = grayColor
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var logOutLabel: UILabel = {
        let label = UILabel()
        label.text = "Log out"
        label.sizeToFit()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        let textRange = NSRange(location: 0, length: label.text!.count)
        let attributedText = NSMutableAttributedString(string: label.text!)
        attributedText.addAttribute(.underlineStyle,
                                    value: NSUnderlineStyle.single.rawValue,
                                    range: textRange)
        label.attributedText = attributedText
        label.numberOfLines = 0
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleLogout)))
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    private func configureUI() {
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissViewController)))
        
        containerView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(blockerGesture)))
        containerView.isUserInteractionEnabled = true
        
        containerView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan)))
        
        view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        view.addSubview(containerView)
        containerView.addSubviews(titleLabel, descriptionLabel, separatorView, orLabel, contactButton, logOutLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 250),
            containerView.widthAnchor.constraint(equalToConstant: 280),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 15),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            contactButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 20),
            contactButton.heightAnchor.constraint(equalToConstant: 35),
            contactButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            contactButton.widthAnchor.constraint(equalToConstant: 200),
            
            orLabel.topAnchor.constraint(equalTo: contactButton.bottomAnchor, constant: 10),
            orLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            separatorView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            separatorView.leadingAnchor.constraint(equalTo: contactButton.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: contactButton.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            logOutLabel.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 10),
            logOutLabel.widthAnchor.constraint(equalToConstant: 100),
            logOutLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            logOutLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        
    }
    
    @objc func handleContact() {
        dismiss(animated: true) {
            self.delegate?.didTapContactSupport()
        }
    }
    
    @objc func handleLogout() {
        print("Did logout")
        dismiss(animated: true) {
            self.delegate?.didTapLogout()
        }
    }
    
    @objc func dismissViewController() {
        dismiss(animated: true)
    }
    
    @objc func blockerGesture() {
        print("no dismiss")
    }
    
    @objc func didPan() {
        print("did pan")
    }
}
