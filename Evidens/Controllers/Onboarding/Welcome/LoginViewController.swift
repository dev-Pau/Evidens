//
//  LoginViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import JGProgressHUD

class LoginViewController: UIViewController {
    
    //MARK: - Properties
  
    private var viewModel = LoginViewModel()
    
    var displayEmailPlaceholder: Bool = false
    var displayPasswordPlaceholder: Bool = false
    
    private var emailTextFieldIsSelected: Bool = false
    private var passwordTextFieldIsSelected: Bool = false
    
    let appearance = UINavigationBarAppearance()
    
    var iconClick = false
    let imageIcon = UIImageView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.backgroundColor = .systemBackground
        scrollView.alwaysBounceVertical = true
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let loginText: UILabel = {
        let label = CustomLabel(placeholder: "Nice to have you back again!")
        return label
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.tintColor = primaryColor
        tf.keyboardType = .emailAddress
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        tf.tintColor = primaryColor
        return tf
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor.withAlphaComponent(0.5)
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Trouble logging in?", for: .normal)
        button.setTitleColor(primaryColor, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let progressIndicator = JGProgressHUD()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureEye()
        setUpDelegates()
        //configureNavigationItemButton()
        configureNotificationsObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        navigationItem.title = "Log In"
        
        view.addSubview(scrollView)
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: view.frame.height)
      
        let stack = UIStackView(arrangedSubviews: [loginText, emailTextField, passwordTextField, loginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            stack.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            stack.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8)
        
        ])

        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
    }
    
    func configureEye() {
        imageIcon.image = UIImage(systemName: "eye.fill")
        imageIcon.tintColor = primaryColor
        
        let contentView = UIView()
        contentView.addSubview(imageIcon)
        
        contentView.frame = CGRect(x: 0, y: 0, width: (UIImage(systemName: "eye.fill")?.size.width)!, height: (UIImage(systemName: "eye.fill")?.size.height)!)
        
        imageIcon.frame = CGRect(x: -10, y: -2.5, width: (UIImage(systemName: "eye.fill")?.size.width)! + 3, height: (UIImage(systemName: "eye.fill")?.size.height)! + 3)
        
        passwordTextField.rightView = contentView
        passwordTextField.rightViewMode = .always
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageIcon.isUserInteractionEnabled = true
        imageIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setUpDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    func configureNotificationsObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    
    
    //MARK: - Actions
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        tappedImage.tintColor = primaryColor
        if iconClick {
            iconClick = false
            tappedImage.image = UIImage(systemName: "eye.slash.fill")
            tappedImage.tintColor = primaryColor
            passwordTextField.isSecureTextEntry = false
        } else {
            iconClick = true
            tappedImage.image = UIImage(systemName: "eye.fill")
            passwordTextField.isSecureTextEntry = true
        }
    }
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
            
        } else {
            viewModel.password = sender.text
        }
        updateForm()
    }
    
    @objc func forgotPasswordButtonPressed() {
        let controller = ResetPasswordViewController()
        controller.delegate = self
        controller.email = emailTextField.text
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""

        navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        progressIndicator.show(in: view)
        
        AuthService.logUserIn(withEmail: email, password: password) { result, error in

            self.progressIndicator.dismiss(animated: true)
            
            if let error = error {
                self.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                return
            }

            //self.dismiss(animated: true, completion: nil)
            let controller = MainTabController()
            //let nav = UINavigationController(rootViewController: controller)
            controller.modalPresentationStyle = .fullScreen
            self.present(controller, animated: false, completion: nil)
        }
    }
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        emailTextFieldIsSelected = textField == emailTextField ? true : false
        passwordTextFieldIsSelected = !emailTextFieldIsSelected
        
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = primaryColor.cgColor
        textField.layer.borderWidth = 2.0

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        emailTextFieldIsSelected = (textField == emailTextField) ? false : emailTextFieldIsSelected
        passwordTextFieldIsSelected = (textField == passwordTextField) ? false : passwordTextFieldIsSelected
        
        textField.backgroundColor = .tertiarySystemGroupedBackground
        textField.layer.borderColor = UIColor.systemBackground.cgColor
        textField.layer.borderWidth = 1.0
        //Secure text entry true by default when user ends editing
        if textField == passwordTextField {
            //textField.isSecureTextEntry = true
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                emailTextField.layer.borderColor = emailTextFieldIsSelected ? primaryColor.cgColor : UIColor.systemBackground.cgColor
                passwordTextField.layer.borderColor = passwordTextFieldIsSelected ? primaryColor.cgColor : UIColor.systemBackground.cgColor
            }
        }
    }
    
}

//MARK: - FormViewModel

extension LoginViewController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.isUserInteractionEnabled = viewModel.formIsValid
    }  
}

//MARK: - ResetPasswordViewControllerDelegate

extension LoginViewController: ResetPasswordViewControllerDelegate {
    func controllerDidSendResetPassword(_ controller: ResetPasswordViewController) {
        navigationController?.popViewController(animated: true)
        self.displayAlert(withTitle: "Success", withMessage: "We have sent password recover instruction to your email.")
    }
}
