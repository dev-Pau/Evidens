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
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private var viewModel = LoginViewModel()
    
    var displayEmailPlaceholder: Bool = false
    var displayPasswordPlaceholder: Bool = false
    
    let appearance = UINavigationBarAppearance()
    
    var iconClick = false
    let imageIcon = UIImageView()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor.withAlphaComponent(0.5)
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private let forgotPasswordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Trouble logging in?", for: .normal)
        button.setTitleColor(primaryColor, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 5
        button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
        button.addTarget(self, action: #selector(forgotPasswordButtonPressed), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpDelegates()
        configureNavigationItemButton()
        configureNotificationsObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }

    //MARK: - Helpers
    
    func configureUI() {
        
        //appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        //navigationItem.standardAppearance = appearance
        navigationItem.title = "Log In"
        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        view.backgroundColor = .white
        
        view.addSubview(scrollView)
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 2.75 * topbarHeight)
        
        //view.backgroundColor = .white
        //navigationController?.navigationBar.isHidden = false
        //navigationController?.navigationBar.barStyle = .black

        let stack = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton, forgotPasswordButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        scrollView.addSubview(stack)
        stack.centerX(inView: scrollView)
        stack.anchor(top: scrollView.topAnchor, paddingTop: 20)
        stack.setWidth(UIScreen.main.bounds.width * 0.8)
       
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(LoginViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
        
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
    
    func configureNavigationItemButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBack))
        navigationController?.navigationBar.tintColor = .black
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
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func didTapBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        spinner.show(in: view)
        
        AuthService.logUserIn(withEmail: email, password: password) { result, error in

            DispatchQueue.main.async {
                self.spinner.dismiss()
            }
            
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
    

    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
}

//MARK: - UITextFieldDelegate

extension LoginViewController: UITextFieldDelegate {
    
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
        //Secure text entry true by default when user ends editing
        if textField == passwordTextField {
            //textField.isSecureTextEntry = true
        }
    }
}

//MARK: - FormViewModel

extension LoginViewController: FormViewModel {
    func updateForm() {
        loginButton.backgroundColor = viewModel.buttonBackgroundColor
        loginButton.isEnabled = viewModel.formIsValid
    }  
}

//MARK: - ResetPasswordViewControllerDelegate

extension LoginViewController: ResetPasswordViewControllerDelegate {
    func controllerDidSendResetPassword(_ controller: ResetPasswordViewController) {
        navigationController?.popViewController(animated: true)
        self.displayAlert(withTitle: "Success", withMessage: "We have sent password recover instruction to your email.")
    }
}

extension LoginViewController {
    //Get height of status bar + navigation bar
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

