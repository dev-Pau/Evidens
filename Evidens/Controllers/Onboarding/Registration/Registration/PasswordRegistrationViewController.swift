//
//  PasswordRegistrationViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class PasswordRegistrationViewController: UIViewController {
    
    private var email: String
    private let imageIcon = UIImageView()
    private var iconClick = false
    private var privacySelected: Bool = false
    private var textFieldSelected: Bool = false
    
    private var viewModel = PasswordRegistrationViewModel()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.backgroundColor = .systemBackground
        scrollView.keyboardDismissMode = .interactive
        return scrollView
    }()
    
    private let passwordTextLabel: UILabel = {
        let label = CustomLabel(placeholder: "Create a password")
        return label
    }()
    
    private let passwordTextField: UITextField = {
        let tf = CustomTextField(placeholder: "Password")
        tf.tintColor = primaryColor
        tf.keyboardType = .default
        tf.isSecureTextEntry = true
        return tf
    }()
    
    private let minCharButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("8 characters", attributes: container)
        
        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let lowerCaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Lower case", attributes: container)
        
        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let upperCaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Upper case", attributes: container)
        
        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let digitCharButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Digit", attributes: container)
        
        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let specialCharButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .filled()
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 12, weight: .semibold)
        button.configuration?.attributedTitle = AttributedString("Special character", attributes: container)
        
        button.configuration?.baseBackgroundColor = .tertiarySystemGroupedBackground
        button.configuration?.baseForegroundColor = .secondaryLabel
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .quaternarySystemFill
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var squareButton: UIButton = {
        let button = UIButton(type: .system)
        button.configuration = .plain()
        button.configuration?.image = UIImage(systemName: "square")?.scalePreservingAspectRatio(targetSize: CGSize(width: 24, height: 24)).withTintColor(primaryColor)
        button.configuration?.baseForegroundColor = primaryColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handlePrivacyConditions), for: .touchUpInside)
        return button
    }()
    
    private lazy var createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor.withAlphaComponent(0.5)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(handleCreateAccount), for: .touchUpInside)
        button.isUserInteractionEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    
    private let conditionsPrivacyString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "By creating a new account you are indicating that you have read and acknowledge the Terms of Service and Privacy Policy.")
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: (aString.string as NSString).range(of: "By creating a new account you are indicating that you have read and acknowledge the Terms of Service and Privacy Policy."))
        
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: (aString.string as NSString).range(of: "By creating a new account you are indicating that you have read and acknowledge the Terms of Service and Privacy Policy."))
        
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "Terms of Service"))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "Privacy Policy"))
        
        //aString.addAttribute(NSAttributedString.Key.link, value: "https://www.google.es/", range: (aString.string as NSString).range(of: "Terms of Service"))
        //aString.addAttribute(NSAttributedString.Key.link, value: "https://www.google.es/", range: (aString.string as NSString).range(of: "Privacy Policy"))
        
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Terms of Service"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Privacy Policy"))
        
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
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    let progressIndicator = JGProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnViewTap()
        configureNavigationBar()
        configureUI()
        setUpDelegates()
        configureEye()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    init(email: String) {
        self.email = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureNavigationBar() {
        title = "Create Account"
    }
    
    private func setUpDelegates() {
        passwordTextField.delegate = self
        passwordTextField.addTarget(self, action: #selector(passwordDidChange), for: .editingChanged)
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        let stackView = UIStackView(arrangedSubviews: [minCharButton, upperCaseButton, lowerCaseButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillProportionally
        stackView.spacing = 2
        stackView.alignment = .center
        
        let bottomStackView = UIStackView(arrangedSubviews: [digitCharButton, specialCharButton])
        bottomStackView.translatesAutoresizingMaskIntoConstraints = false
        bottomStackView.distribution = .fillProportionally
        bottomStackView.spacing = 2
        bottomStackView.alignment = .center

        scrollView.addSubviews(passwordTextLabel, passwordTextField, stackView, bottomStackView, separatorView, squareButton, conditionsPrivacyTextView, createAccountButton)

        NSLayoutConstraint.activate([
            passwordTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            passwordTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            passwordTextLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            passwordTextField.topAnchor.constraint(equalTo: passwordTextLabel.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: passwordTextLabel.leadingAnchor),
            passwordTextField.trailingAnchor.constraint(equalTo: passwordTextLabel.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 12),
            stackView.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            
            bottomStackView.topAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 5),
            bottomStackView.leadingAnchor.constraint(equalTo: stackView.leadingAnchor, constant: 30),
            bottomStackView.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -30),
            
            separatorView.topAnchor.constraint(equalTo: bottomStackView.bottomAnchor, constant: 20),
            separatorView.leadingAnchor.constraint(equalTo: passwordTextField.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: passwordTextField.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            squareButton.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 20),
            squareButton.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            squareButton.heightAnchor.constraint(equalToConstant: 24),
            squareButton.widthAnchor.constraint(equalToConstant: 24),
            
            conditionsPrivacyTextView.topAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: 12),
            conditionsPrivacyTextView.leadingAnchor.constraint(equalTo: squareButton.trailingAnchor, constant: 4),
            conditionsPrivacyTextView.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            
            createAccountButton.topAnchor.constraint(equalTo: conditionsPrivacyTextView.bottomAnchor, constant: 17),
            createAccountButton.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            createAccountButton.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            createAccountButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureEye() {
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
    
    @objc func didTapBack() {
        navigationController?.popViewController(animated: true)
    }
    
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
    
    @objc func passwordDidChange() {
        viewModel.password = passwordTextField.text!
        updateForm()
    }
    
    @objc func handlePrivacyConditions() {
        viewModel.privacySelected.toggle()
        updateForm()
    }
    
    
    
    @objc func handleCreateAccount() {
        guard let password = passwordTextField.text else { return }

        let credentials = AuthCredentials(firstName: "", lastName: "", email: email, password: password, profileImageUrl: "", phase: .categoryPhase, category: .none, profession: "", speciality: "", interests: [])
        
        progressIndicator.show(in: view)
    
        AuthService.registerUser(withCredential: credentials) { error in
            
            if let error = error {
                self.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                return
            }
            
            AuthService.logUserIn(withEmail: self.email, password: password) { result, error in
                
                self.progressIndicator.dismiss(animated: true)
                
                if let error = error {
                    self.displayAlert(withTitle: "Error", withMessage: error.localizedDescription)
                    return
                }
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                
                UserService.fetchUser(withUid: uid) { user in
                    let controller = CategoryRegistrationViewController(user: user)
                    let nav = UINavigationController(rootViewController: controller)
                    nav.modalPresentationStyle = .fullScreen
                    self.present(nav, animated: true)
                }
            }
        }
    }
}

extension PasswordRegistrationViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = primaryColor.cgColor
        textField.layer.borderWidth = 2.0
        textFieldSelected = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .tertiarySystemGroupedBackground
        textField.layer.borderColor = UIColor.white.cgColor
        textField.layer.borderWidth = 1.0
        textFieldSelected = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 passwordTextField.layer.borderColor = textFieldSelected ? primaryColor.cgColor : UIColor.systemBackground.cgColor
             }
         }
    }
}

extension PasswordRegistrationViewController: FormViewModel {
    func updateForm() {
        lowerCaseButton.configuration?.baseBackgroundColor = viewModel.passwordHasLowerCaseLetter ? primaryColor : .tertiarySystemGroupedBackground
        lowerCaseButton.configuration?.baseForegroundColor = viewModel.passwordHasLowerCaseLetter ? .white : .secondaryLabel
        
        upperCaseButton.configuration?.baseBackgroundColor = viewModel.passwordHasUpperCaseLetter ? primaryColor : .tertiarySystemGroupedBackground
        upperCaseButton.configuration?.baseForegroundColor = viewModel.passwordHasUpperCaseLetter ? .white : .secondaryLabel
        
        digitCharButton.configuration?.baseBackgroundColor = viewModel.passwordHasDigit ? primaryColor : .tertiarySystemGroupedBackground
        digitCharButton.configuration?.baseForegroundColor = viewModel.passwordHasDigit ? .white : .secondaryLabel
        
        specialCharButton.configuration?.baseBackgroundColor = viewModel.passwordHasSpecialChar ? primaryColor : .tertiarySystemGroupedBackground
        specialCharButton.configuration?.baseForegroundColor = viewModel.passwordHasSpecialChar ? .white : .secondaryLabel
        
        minCharButton.configuration?.baseBackgroundColor = viewModel.passwordMinChar ? primaryColor : .tertiarySystemGroupedBackground
        minCharButton.configuration?.baseForegroundColor = viewModel.passwordMinChar ? .white : .secondaryLabel
        
        squareButton.configuration?.image = viewModel.privacyConditionsButtonImage
        
        createAccountButton.backgroundColor = viewModel.buttonBackgroundColor
        createAccountButton.isUserInteractionEnabled = viewModel.formIsValid
    }
}

extension PasswordRegistrationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
}
