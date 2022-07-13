//
//  EmailRegistrationViewControllerl.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit

class EmailRegistrationViewController: UIViewController {
    
    private var viewModel = EmailRegistrationViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let emailTextLabel: UILabel = {
        let label = CustomLabel(placeholder: "What is your email?")
        return label
    }()
    
    private let instructionsEmailLabel: UILabel = {
        let label = UILabel()
        label.text = "You will have to confirm this email later on."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    private func configureNavigationBar() {
        title = "Create account"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBack))
        navigationController?.navigationBar.tintColor = .black
    }

    
    private func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.delegate = self
    }
    
    private func configureUI() {
        view.backgroundColor = .white
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(emailTextLabel, emailTextField, instructionsEmailLabel, nextButton)
        
        NSLayoutConstraint.activate([
            emailTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            emailTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            emailTextLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            instructionsEmailLabel.topAnchor.constraint(equalTo: emailTextLabel.bottomAnchor, constant: 10),
            instructionsEmailLabel.leadingAnchor.constraint(equalTo: emailTextLabel.leadingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: instructionsEmailLabel.bottomAnchor, constant: 10),
            emailTextField.leadingAnchor.constraint(equalTo: emailTextLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: emailTextLabel.trailingAnchor),
            
            nextButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            nextButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
        ])
    }
    
    @objc func didTapBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleNext() {
        guard let email = emailTextField.text else { return }
        let controller = PasswordRegistrationViewController(email: email)
        navigationController?.pushViewController(controller, animated: true)
        emailTextField.resignFirstResponder()
    }
    
    @objc func textDidChange() {
        viewModel.email = emailTextField.text
        updateForm()
    }
}

extension EmailRegistrationViewController: UITextFieldDelegate {
    
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

extension EmailRegistrationViewController: FormViewModel {
    func updateForm() {
        nextButton.configuration?.baseBackgroundColor = viewModel.buttonBackgroundColor
        nextButton.isUserInteractionEnabled = viewModel.formIsValid
    }
}

