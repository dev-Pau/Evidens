//
//  RegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 1/10/21.
//

import Foundation
import UIKit

class RegistrationViewController: UIViewController {
    
    //MARK: - Properties
    
    private var timerEmail = Timer()
    
    private var timerPassword = Timer()
    
    private var viewModel = RegistrationViewModel()
    
    private let spinnerEmail: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        return spinner
    }()
    
    private let spinnerPassword: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView()
        spinner.tintColor = UIColor(rgb: 0x79CBBF)
        return spinner
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
        picker.maximumDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())
        return picker
    }()
    
    private let firstNameCheckmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.isEnabled = true
        button.tintColor = .white
        return button
    }()
    
    private let lastNameCheckmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.isEnabled = true
        button.tintColor = .white
        return button
    }()
    
    private let emailCheckmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.isEnabled = true
        button.tintColor = .white
        return button
    }()
    
    private let emailXCheckmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.isEnabled = true
        button.tintColor = .white
        return button
    }()
    
    private let passwordXCheckmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        button.isEnabled = true
        button.tintColor = .white
        return button
    }()
    
    private let passwordCheckmarkButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
        button.isEnabled = true
        button.tintColor = .white
        return button
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: topbarHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topbarHeight)
        scrollView.backgroundColor = .white
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: UIScreen.main.bounds.height)
        return scrollView
    }()
    
    private let fieldIdentifierFirstName: UILabel = {
        let label = UILabel()
        label.text = "First Name"
        label.sizeToFit()
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        label.frame = CGRect(x: 20, y: UIScreen.main.bounds.height * 0.1, width: 200, height: label.frame.height)
        label.textColor = .black
        return label
    }()
    
    let firstNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "")
        tf.keyboardType = .emailAddress
        return tf
    }()

    public let infoLabelFirstName: UILabel = {
        let label = UILabel()
        label.text = "This is the name people will know you by on Evidens. You can always change it later."
        label.font = UIFont(name: "Raleway-Regular", size: 10)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    private let fieldIdentifierLastName: UILabel = {
        let label = UILabel()
        label.text = "Last Name"
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        label.textColor = .black
        return label
    }()
    
    let lastNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    public let infoLabelLastName: UILabel = {
        let label = UILabel()
        label.text = "This is the name placed at the end of your First Name. You can always change it later."
        label.font = UIFont(name: "Raleway-Regular", size: 10)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    private let fieldIdentifierEmail: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        label.textColor = .black
        return label
    }()
    
    let emailTextField: UITextField = {
        let tf = CustomTextField(placeholder: "")
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    public let infoLabelEmail: UILabel = {
        let label = UILabel()
        label.text = "You'll need to verify that you own this email account."
        label.font = UIFont(name: "Raleway-Regular", size: 10)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    private let fieldIdentifierPassword: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        label.textColor = .black
        return label
    }()
    
    let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "")
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
        label.isHidden = true
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
        button.isEnabled = false
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.addSubview(scrollView)
        
        scrollView.addSubview(fieldIdentifierFirstName)
        
        scrollView.addSubview(firstNameTextField)
        firstNameTextField.anchor(top: fieldIdentifierFirstName.bottomAnchor, left: fieldIdentifierFirstName.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingRight: 20)
        
        scrollView.addSubview(infoLabelFirstName)
        infoLabelFirstName.anchor(top: firstNameTextField.bottomAnchor, left: firstNameTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        scrollView.addSubview(firstNameCheckmarkButton)
        firstNameCheckmarkButton.anchor(top: fieldIdentifierFirstName.topAnchor, right: firstNameTextField.rightAnchor)
        
        
        scrollView.addSubview(fieldIdentifierLastName)
        fieldIdentifierLastName.anchor(top: infoLabelFirstName.bottomAnchor, left: infoLabelFirstName.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingRight: 20)

        scrollView.addSubview(lastNameTextField)
        lastNameTextField.anchor(top: fieldIdentifierLastName.bottomAnchor, left: fieldIdentifierLastName.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingRight: 20)
        
        scrollView.addSubview(infoLabelLastName)
        infoLabelLastName.anchor(top: lastNameTextField.bottomAnchor, left: lastNameTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        scrollView.addSubview(lastNameCheckmarkButton)
        lastNameCheckmarkButton.anchor(top: fieldIdentifierLastName.topAnchor, right: lastNameTextField.rightAnchor, paddingTop: -3)
        
        
        
        scrollView.addSubview(fieldIdentifierEmail)
        fieldIdentifierEmail.anchor(top: infoLabelLastName.bottomAnchor, left: infoLabelLastName.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingRight: 20)

        scrollView.addSubview(emailTextField)
        emailTextField.anchor(top: fieldIdentifierEmail.bottomAnchor, left: fieldIdentifierEmail.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingRight: 20)
        
        scrollView.addSubview(infoLabelEmail)
        infoLabelEmail.anchor(top: emailTextField.bottomAnchor, left: emailTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        scrollView.addSubview(emailCheckmarkButton)
        emailCheckmarkButton.anchor(top: fieldIdentifierEmail.topAnchor, right: emailTextField.rightAnchor, paddingTop: -3)
        
        scrollView.addSubview(emailXCheckmarkButton)
        emailXCheckmarkButton.anchor(top: fieldIdentifierEmail.topAnchor, right: emailTextField.rightAnchor, paddingTop: -3)
        
        scrollView.addSubview(spinnerEmail)
        spinnerEmail.anchor(top: emailCheckmarkButton.topAnchor,right: emailCheckmarkButton.leftAnchor, paddingTop: 3, paddingRight: 5)
        

        scrollView.addSubview(fieldIdentifierPassword)
        fieldIdentifierPassword.anchor(top: infoLabelEmail.bottomAnchor, left: infoLabelEmail.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingRight: 20)

        scrollView.addSubview(passwordTextField)
        passwordTextField.anchor(top: fieldIdentifierPassword.bottomAnchor, left: fieldIdentifierPassword.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingRight: 20)
        
        scrollView.addSubview(infoLabelPassword)
        infoLabelPassword.anchor(top: passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        scrollView.addSubview(passwordCheckmarkButton)
        passwordCheckmarkButton.anchor(top: fieldIdentifierPassword.topAnchor, right: passwordTextField.rightAnchor, paddingTop: -3)
        
        scrollView.addSubview(passwordXCheckmarkButton)
        passwordXCheckmarkButton.anchor(top: fieldIdentifierPassword.topAnchor, right: passwordTextField.rightAnchor, paddingTop: -3)
        
        scrollView.addSubview(spinnerPassword)
        spinnerPassword.anchor(top: passwordCheckmarkButton.topAnchor,right: passwordCheckmarkButton.leftAnchor, paddingTop: 3, paddingRight: 5)
        
        scrollView.addSubview(conditionsPrivacyTextView)
        conditionsPrivacyTextView.anchor(top: passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 30, paddingRight: 20)
        
        scrollView.addSubview(createAccountButton)
        createAccountButton.anchor(top: conditionsPrivacyTextView.bottomAnchor, left: conditionsPrivacyTextView.leftAnchor, right: conditionsPrivacyTextView.rightAnchor, paddingTop: 15)
    }
    
    func configureUI() {
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationItem.standardAppearance = appearance
        navigationItem.title = "Create account"
        view.backgroundColor = .white
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.barStyle = .black
        
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
        
        let credentials = AuthCredentials(firstName: firstName, lastName: lastName, email: email, password: password)
        AuthService.registerUser(withCredential: credentials) { error in
            if let error = error {
                print("DEBUG: Failed to register user \(error.localizedDescription)")
                return
            }
            
            //Succesfullly registrates user
            print("DEBUG: Succesfully registrated user with Firestore")
        }

        
    }
    
    @objc func textDidChange(sender: UITextField) {
        if sender == emailTextField {
            viewModel.email = sender.text
            timerEmail.invalidate()
            spinnerEmail.startAnimating()
            timerEmail = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCheckmarkEmail), userInfo: nil, repeats: false)
            
        } else if sender == passwordTextField {
            viewModel.password = sender.text
            timerPassword.invalidate()
            spinnerPassword.startAnimating()
            timerPassword = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCheckmarkPassword), userInfo: nil, repeats: false)

        }
        
        else if sender == firstNameTextField {
            viewModel.firstName = sender.text
            if viewModel.firstNameIsValid {
                firstNameCheckmarkButton.tintColor = UIColor(rgb: 0x79CBBF)
                firstNameTextField.borderStyle = .roundedRect
                firstNameTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                firstNameTextField.layer.borderWidth = 2.0
            } else {
                firstNameCheckmarkButton.tintColor = .white
                firstNameTextField.layer.borderColor = #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
            }
        }
        
        else if sender == lastNameTextField {
            viewModel.lastName = sender.text
            if viewModel.lastNameIsValid {
                lastNameCheckmarkButton.tintColor = UIColor(rgb: 0x79CBBF)
                lastNameTextField.borderStyle = .roundedRect
                lastNameTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                lastNameTextField.layer.borderWidth = 2.0
            } else {
                lastNameCheckmarkButton.tintColor = .white
                lastNameTextField.layer.borderColor = #colorLiteral(red: 0.4274509804, green: 0.431372549, blue: 0.4431372549, alpha: 1)
            }
        }

        updateForm()
    }
    
    @objc func updateCheckmarkEmail() {
        spinnerEmail.stopAnimating()
        if viewModel.emailIsValid {
            infoLabelEmail.text = "You'll need to verify that you own this email account."
            infoLabelEmail.textColor = .black
            
            emailXCheckmarkButton.tintColor = .clear
            emailCheckmarkButton.tintColor = UIColor(rgb: 0x79CBBF)
            
            emailTextField.borderStyle = .roundedRect
            emailTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
            emailTextField.layer.borderWidth = 2.0
        } else {
            infoLabelEmail.text = "Please enter a valid password."
            infoLabelEmail.textColor = .red
            
            emailXCheckmarkButton.tintColor = .red
            emailCheckmarkButton.tintColor = .clear
            
            emailTextField.borderStyle = .roundedRect
            emailTextField.layer.borderColor = UIColor.red.cgColor
            emailTextField.layer.borderWidth = 2.0
        }
    }
    
    @objc func updateCheckmarkPassword() {
        spinnerPassword.stopAnimating()
        if viewModel.passwordIsValid {
            infoLabelPassword.text = "Strong passwords include a mix of lower case letters, upper case letters, numbers, and special characters."
            infoLabelPassword.textColor = .black
            
            passwordXCheckmarkButton.tintColor = .clear
            passwordCheckmarkButton.tintColor = UIColor(rgb: 0x79CBBF)
            
            passwordTextField.borderStyle = .roundedRect
            passwordTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
            passwordTextField.layer.borderWidth = 2.0
        } else {
            infoLabelPassword.text = "Please enter a valid email address."
            infoLabelPassword.textColor = .red
            
            passwordXCheckmarkButton.tintColor = .red
            passwordCheckmarkButton.tintColor = .clear
            
            passwordTextField.borderStyle = .roundedRect
            passwordTextField.layer.borderColor = UIColor.red.cgColor
            passwordTextField.layer.borderWidth = 2.0
        }
    }
    
    @objc func didTapBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
}

extension RegistrationViewController {
    //Get height of status bar + navigation bar
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
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
            infoLabelFirstName.isHidden = false
            if viewModel.firstNameIsValid {
                firstNameTextField.borderStyle = .roundedRect
                firstNameTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                firstNameTextField.layer.borderWidth = 2.0
            }

        case lastNameTextField:
            infoLabelLastName.isHidden = false
            if viewModel.firstNameIsValid {
                lastNameTextField.borderStyle = .roundedRect
                lastNameTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                lastNameTextField.layer.borderWidth = 2.0
            }
            
        case emailTextField:
            infoLabelEmail.isHidden = false
            if viewModel.emailIsValid {
                emailTextField.borderStyle = .roundedRect
                emailTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                emailTextField.layer.borderWidth = 2.0
            }
            else if viewModel.emailIsValid == false && emailTextField.text?.count != 0 {
                emailTextField.layer.borderColor = UIColor.red.cgColor
            }
            
        case passwordTextField:
            infoLabelPassword.isHidden = false
            if viewModel.passwordIsValid {
                passwordTextField.borderStyle = .roundedRect
                passwordTextField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
                passwordTextField.layer.borderWidth = 2.0
            }
            else if viewModel.passwordIsValid == false && passwordTextField.text?.count != 0 {
                passwordTextField.layer.borderColor = UIColor.red.cgColor
            }
            
        default:
            print("default 432423")
        }
    }
     
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        textField.layer.borderColor = UIColor.white.cgColor
        
        switch textField {
        case firstNameTextField:
            infoLabelFirstName.isHidden = true

        case lastNameTextField:
            infoLabelLastName.isHidden = true
            
        case emailTextField:
            infoLabelEmail.isHidden = true
    
        case passwordTextField:
            infoLabelPassword.isHidden = true
            
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



