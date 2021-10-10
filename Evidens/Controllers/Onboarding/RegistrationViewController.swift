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
        tf.keyboardType = .emailAddress
        return tf
    }()
    
    
    public let infoLabelFirstName: UILabel = {
        let label = UILabel()
        label.text = "This is the name people will know you by on Evidens. You can always change it later"
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
        label.text = "This is the name placed at the end of your First Name. You can always change it later"
        label.font = UIFont(name: "Raleway-Regular", size: 10)
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        label.isHidden = true
        return label
    }()

    let appearance = UINavigationBarAppearance()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        setUpDelegates()
        configureNavigationItemButton()
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
        firstNameTextField.anchor(top: fieldIdentifierFirstName.bottomAnchor, left: fieldIdentifierFirstName.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        scrollView.addSubview(infoLabelFirstName)
        infoLabelFirstName.anchor(top: firstNameTextField.bottomAnchor, left: firstNameTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        
        
        scrollView.addSubview(fieldIdentifierLastName)
        fieldIdentifierLastName.anchor(top: infoLabelFirstName.bottomAnchor, left: infoLabelFirstName.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingTop: 10, paddingRight: 20)

        scrollView.addSubview(lastNameTextField)
        lastNameTextField.anchor(top: fieldIdentifierLastName.bottomAnchor, left: fieldIdentifierLastName.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
        scrollView.addSubview(infoLabelLastName)
        infoLabelLastName.anchor(top: lastNameTextField.bottomAnchor, left: lastNameTextField.leftAnchor, right: view.safeAreaLayoutGuide.rightAnchor, paddingRight: 20)
        
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
    }
    
    //MARK: - Actions
    
    @objc func keyboardDismiss() {
        view.endEditing(true)
    }
    
    @objc func didTapBack() {
        self.navigationController?.popToRootViewController(animated: true)
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
        
        infoLabelFirstName.isHidden = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = #colorLiteral(red: 0.9215686275, green: 0.9215686275, blue: 0.9215686275, alpha: 1)
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1.0
        infoLabelFirstName.isHidden = true
            
            //Secure text entry true by default when user ends editing
            //if textField == passwordTextField {
            //    textField.isSecureTextEntry = true
            //}
    }
}



