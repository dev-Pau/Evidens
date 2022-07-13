//
//  ResetPasswordViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 3/10/21.
//

import UIKit

protocol ResetPasswordViewControllerDelegate: AnyObject {
    func controllerDidSendResetPassword(_ controller: ResetPasswordViewController)
}

class ResetPasswordViewController: UIViewController {
    
    //MARK: - Properties
    
    let appearance = UINavigationBarAppearance()
    
    var email: String?
    
    private var viewModel = ResetPasswordViewModel()
    
    weak var delegate: ResetPasswordViewControllerDelegate?
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let resetPasswordLabel: UILabel = {
        let label = CustomLabel(placeholder: "Reset your password")
        return label
    }()
    
    private let instructionsPassword: UILabel = {
        let label = UILabel()
        label.text = "Enter the email associated with your account and we'll send an email with instructions to reset your password."
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = grayColor
        label.numberOfLines = 0
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        tf.tintColor = primaryColor
        return tf
    }()
    
    private lazy var resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset password", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor.withAlphaComponent(0.5)
        button.isEnabled = false
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpDelegates()
        configureNotificationsObservers()
        configureNavigationItemButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: Helpers
    
    func configureUI() {
        view.backgroundColor = .white
        navigationItem.title = "Forgot password"
        
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(resetPasswordLabel, instructionsPassword, emailTextField, resetButton)
        
        NSLayoutConstraint.activate([
            resetPasswordLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            resetPasswordLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            resetPasswordLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            instructionsPassword.topAnchor.constraint(equalTo: resetPasswordLabel.bottomAnchor, constant: 5),
            instructionsPassword.leadingAnchor.constraint(equalTo: resetPasswordLabel.leadingAnchor),
            instructionsPassword.trailingAnchor.constraint(equalTo: resetPasswordLabel.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: instructionsPassword.bottomAnchor, constant: 10),
            emailTextField.leadingAnchor.constraint(equalTo: resetPasswordLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: resetPasswordLabel.trailingAnchor),
            
            resetButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            resetButton.leadingAnchor.constraint(equalTo: emailTextField.leadingAnchor),
            resetButton.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor),
            resetButton.heightAnchor.constraint(equalToConstant: 50)
             
            
        ])
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ResetPasswordViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
        
        emailTextField.text = email
        viewModel.email = email
        updateForm()
    }
    
    func setUpDelegates() {
        emailTextField.delegate = self
    }
    
    func configureNotificationsObservers() {
            emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }
    
    func configureNavigationItemButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBack))
        navigationController?.navigationBar.tintColor = .black
    }
    
    //MARK:  - Actions
    
    @objc func didTapBack() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func resetButtonPressed() {
        guard let email = emailTextField.text else { return }
        showLoadingView()
        AuthService.resetPassword(withEmail: email) { error in
            self.dismissLoadingView()
            if let error = error {
                self.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                return
            } else {
                self.delegate?.controllerDidSendResetPassword(self)
            }
        }
    }
    
    @objc func textDidChange(sender: UITextField) {
        viewModel.email = sender.text
        updateForm()
    }
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
}

//MARK: - UITextFieldDelegate

extension ResetPasswordViewController: UITextFieldDelegate {
    
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


//MARK: - FormViewModel

extension ResetPasswordViewController: FormViewModel {
    func updateForm() {
        resetButton.backgroundColor = viewModel.buttonBackgroundColor
        resetButton.isEnabled = viewModel.formIsValid
    }
}


