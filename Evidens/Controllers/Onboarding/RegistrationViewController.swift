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
    
    private var didUserEditEmail = false
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        }
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
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = CGRect(x: 0, y: topbarHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - topbarHeight)
        scrollView.backgroundColor = .white
        scrollView.contentSize = CGSize(width: view.frame.size.width, height: 2200)
        return scrollView
    }()
    
    private let fieldIdentifierFirstName: UILabel = {
        let label = UILabel()
        label.text = "First Name"
        label.sizeToFit()
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        label.frame = CGRect(x: 20, y: 0, width: 200, height: label.frame.height)
        label.textColor = .black
        return label
    }()
    
    let firstNameTextField: UITextField = {
        let tf = CustomTextField(placeholder: "")
        tf.addTarget(self, action: #selector(textFieldFirstNameDidChange(_:)), for: .editingChanged)
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
        tf.addTarget(self, action: #selector(textFieldLastNameDidChange(_:)), for: .editingChanged)
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
        //tf.addTarget(self, action: #selector(textFieldEmailDidChange(_:)), for: .editingChanged)
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
        tf.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
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
    
    
    private let fieldIdentifierDateOfBirth: UILabel = {
        let label = UILabel()
        label.text = "Date of Birth"
        label.font = UIFont(name: "Raleway-Bold", size: 15)
        label.textColor = .black
        return label
    }()
    
    private let dateOfBirthTextField: UITextField = {
        let tf = CustomTextField(placeholder: "")
        return tf
    }()
    
    private let conditionsPrivacyString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "By clicking Create account you are indicating that you have read and acknowledge the Terms of Service and Privacy Policy.")
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont(name: "Raleway-Regular", size: 13)!, range: (aString.string as NSString).range(of: "By clicking Create account you are indicating that you have read and acknowledge the Terms of Service and Privacy Policy."))
        
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
    
    let appearance = UINavigationBarAppearance()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpDelegates()
        configureNavigationItemButton()
        createDatePicker()
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
        
        
        
        scrollView.addSubview(fieldIdentifierPassword)
        fieldIdentifierPassword.anchor(top: infoLabelEmail.bottomAnchor, left: infoLabelEmail.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingRight: 20)

        scrollView.addSubview(passwordTextField)
        passwordTextField.anchor(top: fieldIdentifierPassword.bottomAnchor, left: fieldIdentifierPassword.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingRight: 20)
        
        scrollView.addSubview(infoLabelPassword)
        infoLabelPassword.anchor(top: passwordTextField.bottomAnchor, left: passwordTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        
        
        scrollView.addSubview(fieldIdentifierDateOfBirth)
        fieldIdentifierDateOfBirth.anchor(top: infoLabelPassword.bottomAnchor, left: infoLabelPassword.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingRight: 20)

        scrollView.addSubview(dateOfBirthTextField)
        dateOfBirthTextField.anchor(top: fieldIdentifierDateOfBirth.bottomAnchor, left: fieldIdentifierDateOfBirth.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 5, paddingRight: 20)
        
        
        scrollView.addSubview(conditionsPrivacyTextView)
        conditionsPrivacyTextView.anchor(top: dateOfBirthTextField.bottomAnchor, left: dateOfBirthTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 20, paddingRight: 20)
        
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
    
    func createDatePicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([doneButton], animated: true)
        
        dateOfBirthTextField.inputAccessoryView = toolbar
        dateOfBirthTextField.inputView = datePicker
    }
    
    //MARK: - Actions
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        switch textField.text!.count {
        case 1...7:
            textField.layer.borderColor = #colorLiteral(red: 0.8935089724, green: 0.02982135535, blue: 0, alpha: 1)
            infoLabelPassword.text = "Password must be between 8 to 70 characters."
            infoLabelPassword.textColor = #colorLiteral(red: 0.8935089724, green: 0.02982135535, blue: 0, alpha: 1)
            
        default:
            print("default")
        }
    }
    
    @objc func textFieldFirstNameDidChange(_ textField: UITextField) {
        firstNameCheckmarkButton.tintColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
        if textField.text?.count == 0 {
            firstNameCheckmarkButton.tintColor = .white
        }
    }
    
    @objc func textFieldLastNameDidChange(_ textField: UITextField) {
        lastNameCheckmarkButton.tintColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
        if textField.text?.count == 0 {
            lastNameCheckmarkButton.tintColor = .white
        }
    }
    
    @objc func textFieldEmailDidChange(_ textField: UITextField) {
        //emailCheckmarkButton.tintColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
        if textField.text?.isValidEmail() == false {
            emailCheckmarkButton.tintColor = .white
        } else {
            emailCheckmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            emailCheckmarkButton.tintColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
        }
    }
    
    @objc func didTapBack() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func donePressed() {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateOfBirthTextField.text = formatter.string(from: datePicker.date)
        view.endEditing(true)
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
        textField.layer.borderColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
        textField.layer.borderWidth = 2.0
        
        switch textField {
        case firstNameTextField:
            infoLabelFirstName.isHidden = false
            
        case lastNameTextField:
            infoLabelLastName.isHidden = false
            
        case emailTextField:
            infoLabelEmail.isHidden = false
            
            if (didUserEditEmail && emailTextField.text?.isValidEmail() == false){
                emailTextField.layer.borderColor = #colorLiteral(red: 0.8935089724, green: 0.02982135535, blue: 0, alpha: 1)
            }
            
            else if emailTextField.text?.count == 0 {
                emailCheckmarkButton.tintColor = .white
            }
            
            else if (emailTextField.text?.isValidEmail() == false && emailTextField.text?.count != 0) {
                emailTextField.layer.borderColor = #colorLiteral(red: 0.8935089724, green: 0.02982135535, blue: 0, alpha: 1)
                emailCheckmarkButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                emailCheckmarkButton.tintColor = #colorLiteral(red: 0.8935089724, green: 0.02982135535, blue: 0, alpha: 1)
            } else {
                infoLabelEmail.isHidden = false
                infoLabelEmail.text = "You'll need to verify that you own this email account."
                infoLabelEmail.textColor = .black
                infoLabelEmail.backgroundColor = .white
                infoLabelEmail.layer.borderColor = UIColor.white.cgColor
                infoLabelEmail.layer.borderWidth = 1.0
                emailCheckmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
            }
            
        case passwordTextField:
            infoLabelPassword.isHidden = false
            
        default:
            print("default")
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        switch textField {
        case firstNameTextField:
            infoLabelFirstName.isHidden = true
            firstNameTextField.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            firstNameTextField.layer.borderColor = UIColor.white.cgColor
            firstNameTextField.layer.borderWidth = 1.0
            if (firstNameTextField.text?.count == 0) {
                firstNameCheckmarkButton.tintColor = .white
            }
            
        case lastNameTextField:
            infoLabelLastName.isHidden = true
            lastNameTextField.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            lastNameTextField.layer.borderColor = UIColor.white.cgColor
            lastNameTextField.layer.borderWidth = 1.0
            
            if (lastNameTextField.text?.count == 0) {
                lastNameCheckmarkButton.tintColor = .white
            }
            
        case emailTextField:
            didUserEditEmail = true
            infoLabelEmail.isHidden = true
            infoLabelEmail.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
            infoLabelEmail.layer.borderColor = UIColor.white.cgColor
            infoLabelEmail.layer.borderWidth = 1.0
            
            if ((emailTextField.text?.isValidEmail()) == false) {
                emailTextField.layer.borderColor = #colorLiteral(red: 0.8935089724, green: 0.02982135535, blue: 0, alpha: 1)
                infoLabelEmail.text = "Please enter a valid email address."
                infoLabelEmail.textColor = #colorLiteral(red: 0.8935089724, green: 0.02982135535, blue: 0, alpha: 1)
                infoLabelEmail.backgroundColor = .white
                emailCheckmarkButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
                emailCheckmarkButton.tintColor = #colorLiteral(red: 0.8935089724, green: 0.02982135535, blue: 0, alpha: 1)
                infoLabelEmail.isHidden = false
                
                
            } else {
                infoLabelEmail.text = "You'll need to verify that you own this email account."
                infoLabelEmail.isHidden = true
                infoLabelEmail.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
                emailTextField.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
                emailTextField.layer.borderColor = UIColor.white.cgColor
                print("did end editing and email is correct")
                infoLabelEmail.layer.borderColor = UIColor.white.cgColor
                infoLabelEmail.layer.borderWidth = 1.0
                emailCheckmarkButton.setImage(UIImage(systemName: "checkmark.circle.fill"), for: .normal)
                emailCheckmarkButton.tintColor = #colorLiteral(red: 0.5381981134, green: 0.8285184503, blue: 0.7947158217, alpha: 1)
            }
        case passwordTextField:
            infoLabelPassword.isHidden = true
            
        default:
            print("default")
        }
    }
}

extension RegistrationViewController: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
}



