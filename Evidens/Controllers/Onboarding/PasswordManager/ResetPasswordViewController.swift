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
    
    private let resetPassword: UILabel = {
        let label = CustomLabel(placeholder: "Reset your password")
        return label
    }()
    
    private let instructionsPassword: UILabel = {
        let label = UILabel()
        label.text = "Enter the email associated with your account and we'll send an email with instructions to reset your password."
        label.font = .systemFont(ofSize: 11, weight: .regular)
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
        button.backgroundColor = primaryColor.withAlphaComponent(0.5)
        button.setHeight(50)
        button.isEnabled = false
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(resetButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpDelegates()
        configureNotificationsObservers()
        configureNavigationItemButton()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: Helpers
    
    func configureUI() {
        view.backgroundColor = .white

        emailTextField.text = email
        viewModel.email = email
        updateForm()

        let stack = UIStackView(arrangedSubviews: [resetPassword, instructionsPassword, emailTextField, resetButton])
        stack.axis = .vertical
        stack.spacing = 20
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.centerY(inView: view)
        stack.anchor(left: view.safeAreaLayoutGuide.leftAnchor, paddingLeft: 30)
        stack.anchor(right: view.safeAreaLayoutGuide.leftAnchor, paddingRight: 20)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ResetPasswordViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
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
        AuthService.resetPassword(withEmail: email) { error in
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
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = 0 - keyboardSize.height * 0.5
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
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
