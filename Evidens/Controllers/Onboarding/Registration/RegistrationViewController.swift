//
//  RegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import UIKit
import JGProgressHUD

class RegistrationViewController: UIViewController {
    
    //MARK: - Properties
    
    private let spinner = JGProgressHUD(style: .dark)

    private var viewModel = RegistrationViewModel()
    
    let firstNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "First name")
        tf.keyboardType = .emailAddress
        return tf
    }()

    let lastNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Last name")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Email")
        tf.keyboardType = .emailAddress
        return tf
    }()

    let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.keyboardType = .emailAddress
        tf.isSecureTextEntry = true
        return tf
    }()
    
    public let infoLabelPassword: UILabel = {
        let label = UILabel()
        label.text = "Strong passwords include a mix of lower case letters, upper case letters, numbers, and special characters."
        label.font = UIFont(name: "Raleway-Regular", size: 10)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    private let conditionsPrivacyString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "By clicking Continue you are indicating that you have read and acknowledge the Terms of Service and Privacy Policy.")
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Raleway-Regular", size: 13)!, range: (aString.string as NSString).range(of: "By clicking Continue you are indicating that you have read and acknowledge the Terms of Service and Privacy Policy."))
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Raleway-Bold", size: 13)!, range: (aString.string as NSString).range(of: "Terms of Service"))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Raleway-Bold", size: 13)!, range: (aString.string as NSString).range(of: "Privacy Policy"))
        
        aString.addAttribute(NSAttributedString.Key.link, value: "https://www.google.es/", range: (aString.string as NSString).range(of: "Terms of Service"))
        aString.addAttribute(NSAttributedString.Key.link, value: "https://www.google.es/", range: (aString.string as NSString).range(of: "Privacy Policy"))
        
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(rgb: 0x79CBBF), range: (aString.string as NSString).range(of: "Terms of Service"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(rgb: 0x79CBBF), range: (aString.string as NSString).range(of: "Privacy Policy"))
        
        return aString
    }()
    
    lazy var conditionsPrivacyTextView: UITextView = {
        let tv = UITextView()
        tv.attributedText = conditionsPrivacyString
        tv.delegate = self
        tv.isSelectable = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        return tv
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0x79CBBF).withAlphaComponent(0.5)
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont(name: "Raleway-Bold", size: 18)
        button.addTarget(self, action: #selector(createAccountButtonPressed), for: .touchUpInside)
        button.isEnabled = true
        return button
    }()
    
    let appearance = UINavigationBarAppearance()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpDelegates()
        configureNavigationItemButton()
        configureNotificationsObservers()
        //createDatePicker()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        firstNameTextField.becomeFirstResponder()
    }
    
    //MARK: - Helpers
    
    func configureUI() {
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationItem.standardAppearance = appearance
        navigationItem.title = "Create account"
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .black
        
        let stack = UIStackView(arrangedSubviews: [firstNameTextField, lastNameTextField, emailTextField, passwordTextField, infoLabelPassword])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.centerX(inView: view)
        stack.anchor(top: view.topAnchor, paddingTop: UIScreen.main.bounds.height * 0.25)
        stack.setWidth(UIScreen.main.bounds.width * 0.8)
        
        view.addSubview(infoLabelPassword)
        infoLabelPassword.anchor(top: stack.bottomAnchor, left: stack.leftAnchor, right: stack.rightAnchor, paddingTop: 5, paddingLeft: 4)
        
        let stack2 = UIStackView(arrangedSubviews: [conditionsPrivacyTextView, createAccountButton])
        stack2.axis = .vertical
        stack2.spacing = 10
        
        view.addSubview(stack2)
        stack2.anchor(top: infoLabelPassword.bottomAnchor, left: stack.leftAnchor, right: stack.rightAnchor, paddingTop: 20)
        stack2.setWidth(UIScreen.main.bounds.width * 0.8)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(RegistrationViewController.keyboardDismiss))
        view.addGestureRecognizer(tap)
    }
    
    func configureNavigationItemButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: .init(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(didTapBack))
        navigationController?.navigationBar.tintColor = .black
    }
    
    func setUpDelegates() {
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }

    func configureNotificationsObservers() {
        firstNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        lastNameTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            self.view.frame.origin.y = 0 - keyboardSize.height * 0.3
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
 
    
    //MARK: - Actions
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @objc func createAccountButtonPressed() {
        guard let firstName = firstNameTextField.text else { return }
        guard let lastName = lastNameTextField.text else { return }
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        
        spinner.show(in: view)
        
        let credentials = AuthCredentials(firstName: firstName, lastName: lastName, email: email, password: password, profileImageUrl: "")
        
        let controller = InfoRegistrationViewController(credentials: credentials)
        controller.firstName = firstName

        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true, completion: nil)
    
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
            if viewModel.emailIsValid {
                emailTextField.borderStyle = .roundedRect
                emailTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                emailTextField.layer.borderWidth = 2.0
            } else {
                emailTextField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            }
        }
        
        else if sender == passwordTextField {
            viewModel.password = sender.text
            if viewModel.passwordIsValid {
                passwordTextField.borderStyle = .roundedRect
                passwordTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                passwordTextField.layer.borderWidth = 2.0
            } else {
                passwordTextField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            }
        }
        
        else if sender == firstNameTextField {
            viewModel.firstName = sender.text
            if viewModel.firstNameIsValid {
                firstNameTextField.borderStyle = .roundedRect
                firstNameTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                firstNameTextField.layer.borderWidth = 2.0
            } else {
                firstNameTextField.layer.borderColor = #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
            }
        }
        
        else if sender == lastNameTextField {
            viewModel.lastName = sender.text
            if viewModel.lastNameIsValid {
                lastNameTextField.borderStyle = .roundedRect
                lastNameTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                lastNameTextField.layer.borderWidth = 2.0
            } else {
                lastNameTextField.layer.borderColor = #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
            }
             
        }
        updateForm()
    }
    
    @objc func didTapBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
}

extension RegistrationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
        textField.layer.borderWidth = 2.0
        
        switch textField {
        case firstNameTextField:
            //infoLabelFirstName.isHidden = false
            if viewModel.firstNameIsValid {
                firstNameTextField.borderStyle = .roundedRect
                firstNameTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                firstNameTextField.layer.borderWidth = 2.0
            }

        case lastNameTextField:
            //infoLabelLastName.isHidden = false
            if viewModel.lastNameIsValid {
                lastNameTextField.borderStyle = .roundedRect
                lastNameTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                lastNameTextField.layer.borderWidth = 2.0
            }
            
        case emailTextField:
            //infoLabelEmail.isHidden = false
            if viewModel.emailIsValid {
                emailTextField.borderStyle = .roundedRect
                emailTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                emailTextField.layer.borderWidth = 2.0
            }
            else if viewModel.emailIsValid == false && emailTextField.text?.count != 0 {
                emailTextField.layer.borderColor = UIColor.red.cgColor
            }
            
        case passwordTextField:
            //infoLabelPassword.isHidden = false
            if viewModel.passwordIsValid {
                passwordTextField.borderStyle = .roundedRect
                passwordTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                passwordTextField.layer.borderWidth = 2.0
            }
            else if viewModel.passwordIsValid == false && passwordTextField.text?.count != 0 {
                passwordTextField.layer.borderColor = UIColor.red.cgColor
            }
            
        default:
            print("default")
        }
    }
     
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        textField.layer.borderColor = UIColor.white.cgColor
        
        switch textField {
        case passwordTextField:
            if !viewModel.passwordIsValid {
                textField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else {
                textField.layer.borderColor = UIColor.white.cgColor
            }
            
        case emailTextField:
            if !viewModel.emailIsValid {
                textField.layer.borderColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            } else {
                textField.layer.borderColor = UIColor.white.cgColor
            }

        default:
            print("default")
        }
    }
}

//MARK: - UITextViewDelegate

extension RegistrationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}

//MARK: - FormViewModel

extension RegistrationViewController: FormViewModel {
    func updateForm() {
        createAccountButton.backgroundColor = viewModel.buttonBackgroundColor
        createAccountButton.isEnabled = viewModel.formIsValid
    }
}



