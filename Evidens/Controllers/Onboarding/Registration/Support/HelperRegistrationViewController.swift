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
    
    private lazy var dismissButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.baseBackgroundColor = lightColor
        button.configuration?.image = UIImage(named: "xmark")?.scalePreservingAspectRatio(targetSize: CGSize(width: 18, height: 18)).withTintColor(primaryColor)
        button.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.layer.cornerRadius = 3
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let separatorView : UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.layer.cornerRadius = 1
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let bottomSeparatorView : UIView = {
        let view = UIView()
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "We're here to help"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 18, weight: .heavy)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Our support team is here to help you. Contact us at support@myevidens.com if you need any assistance during the registration process."
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .black
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
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleContact), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        label.font = .systemFont(ofSize: 16, weight: .semibold)
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

        view.backgroundColor = .white
        view.addSubviews(separator, dismissButton, titleLabel, separatorView, descriptionLabel, contactButton, bottomSeparatorView, logOutLabel )
      
        NSLayoutConstraint.activate([
            separator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separator.topAnchor.constraint(equalTo: view.topAnchor, constant: 7),
            separator.heightAnchor.constraint(equalToConstant: 5),
            separator.widthAnchor.constraint(equalToConstant: 50),
            
            dismissButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            dismissButton.heightAnchor.constraint(equalToConstant: 30),
            dismissButton.widthAnchor.constraint(equalToConstant: 30),
            
            titleLabel.topAnchor.constraint(equalTo: dismissButton.bottomAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            separatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            separatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            separatorView.widthAnchor.constraint(equalToConstant: view.frame.width - 20),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            contactButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
            contactButton.heightAnchor.constraint(equalToConstant: 35),
            contactButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            contactButton.widthAnchor.constraint(equalToConstant: 200),
            
            //orLabel.topAnchor.constraint(equalTo: contactButton.bottomAnchor, constant: 13),
            //orLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            //bottomSeparatorView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            //bottomSeparatorView.leadingAnchor.constraint(equalTo: contactButton.leadingAnchor),
            //bottomSeparatorView.trailingAnchor.constraint(equalTo: contactButton.trailingAnchor),
            //bottomSeparatorView.heightAnchor.constraint(equalToConstant: 1),
            
            logOutLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            logOutLabel.widthAnchor.constraint(equalToConstant: 100),
            logOutLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logOutLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc func handleContact() {
        dismiss(animated: true) {
            self.delegate?.didTapContactSupport()
        }
    }
    
    @objc func handleLogout() {
        dismiss(animated: true) {
            self.delegate?.didTapLogout()
        }
    }
    
    @objc func handleDismiss() {
        dismiss(animated: true)
    }
}
