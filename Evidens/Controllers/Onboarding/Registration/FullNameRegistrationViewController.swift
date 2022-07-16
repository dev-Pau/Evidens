//
//  FullNameViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 15/7/22.
//

import UIKit

class FullNameRegistrationViewController: UIViewController {
    
    private var user: User
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .white
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let nameTextLabel: UILabel = {
        let label = CustomLabel(placeholder: "What's your name?")
        return label
    }()
    
    private let instructionsNameLabel: UILabel = {
        let label = UILabel()
        label.text = "This will be displayed on your profile as your full name. You can always change that later."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let firstNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "First name")
        tf.tintColor = primaryColor
        tf.keyboardType = .emailAddress
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private let lastNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Last name")
        tf.tintColor = primaryColor
        tf.keyboardType = .emailAddress
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        button.configuration?.image = UIImage(named: "arrow.right")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20)).withTintColor(.white)
        button.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isUserInteractionEnabled = false
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
        configureNotificationObservers()
    }
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Account details"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "questionmark.circle.fill"), style: .done, target: self, action: #selector(handleHelp))
        navigationItem.rightBarButtonItem?.tintColor = grayColor
        
    }
    
    private func configureNotificationObservers() {
        firstNameTextField.delegate = self
        firstNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        lastNameTextField.delegate = self
        lastNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(nameTextLabel, instructionsNameLabel, firstNameTextField, lastNameTextField, nextButton)
        
        NSLayoutConstraint.activate([
            nameTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            nameTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            nameTextLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            instructionsNameLabel.topAnchor.constraint(equalTo: nameTextLabel.bottomAnchor, constant: 10),
            instructionsNameLabel.leadingAnchor.constraint(equalTo: nameTextLabel.leadingAnchor),
            instructionsNameLabel.trailingAnchor.constraint(equalTo: nameTextLabel.trailingAnchor),
            
            firstNameTextField.topAnchor.constraint(equalTo: instructionsNameLabel.bottomAnchor, constant: 10),
            firstNameTextField.leadingAnchor.constraint(equalTo: instructionsNameLabel.leadingAnchor),
            firstNameTextField.trailingAnchor.constraint(equalTo: instructionsNameLabel.trailingAnchor),
            
            lastNameTextField.topAnchor.constraint(equalTo: firstNameTextField.bottomAnchor, constant: 5),
            lastNameTextField.leadingAnchor.constraint(equalTo: firstNameTextField.leadingAnchor),
            lastNameTextField.trailingAnchor.constraint(equalTo: firstNameTextField.trailingAnchor),
            
            nextButton.topAnchor.constraint(equalTo: lastNameTextField.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: lastNameTextField.trailingAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    @objc func textDidChange() {
        if firstNameTextField.text != "" && lastNameTextField.text != "" {
            nextButton.isUserInteractionEnabled = true
            nextButton.configuration?.baseBackgroundColor = primaryColor
        } else {
            nextButton.isUserInteractionEnabled = false
            nextButton.configuration?.baseBackgroundColor = primaryColor.withAlphaComponent(0.5)
        }
    }
    
    @objc func handleHelp() {
        
    }
    
    @objc func handleNext() {
        guard let firstName = firstNameTextField.text, let lastName = lastNameTextField.text else { return }
        user.firstName = firstName
        user.lastName = lastName
        
        let controller = ImageRegistrationViewController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension FullNameRegistrationViewController: UITextFieldDelegate {
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
    }
}
