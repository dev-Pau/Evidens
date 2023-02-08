//
//  EmailRegistrationViewControllerl.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit

class EmailRegistrationViewController: UIViewController {
    
    private var viewModel = EmailRegistrationViewModel()
    private var whoCanJoinMenuLauncher = WhoCanJoinMenuLauncher()
    
    private var textFieldSelected: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .interactive
        scrollView.backgroundColor = .systemBackground
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
        label.textColor = .secondaryLabel
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
    
    private let conditionsCategoryString: NSMutableAttributedString = {
        let aString = NSMutableAttributedString(string: "At MyEvidens we verify our entire community. Who can join MyEvidens?")
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .regular), range: (aString.string as NSString).range(of: "At MyEvidens we verify our entire community. Who can join MyEvidens?"))
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: grayColor, range: (aString.string as NSString).range(of: "At MyEvidens we verify our entire community. Who can join MyEvidens?"))
        aString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 13, weight: .semibold), range: (aString.string as NSString).range(of: "Who can join MyEvidens?"))
        
        aString.addAttribute(NSAttributedString.Key.link, value: "presentCommunityInformation", range: (aString.string as NSString).range(of: "Who can join MyEvidens?"))
        
        aString.addAttribute(NSAttributedString.Key.foregroundColor, value: primaryColor, range: (aString.string as NSString).range(of: "Who can join MyEvidens?"))
        
        return aString
    }()
    
    lazy var instructionsJoin: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
        tv.attributedText = conditionsCategoryString
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.delegate = self
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnViewTap()
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
    }

    
    private func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.delegate = self
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        view.addSubview(scrollView)
        
        scrollView.addSubviews(emailTextLabel, emailTextField, instructionsEmailLabel, nextButton, instructionsJoin)
        
        NSLayoutConstraint.activate([
            emailTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 10),
            emailTextLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            emailTextLabel.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            instructionsEmailLabel.topAnchor.constraint(equalTo: emailTextLabel.bottomAnchor, constant: 10),
            instructionsEmailLabel.leadingAnchor.constraint(equalTo: emailTextLabel.leadingAnchor),
            instructionsEmailLabel.trailingAnchor.constraint(equalTo: emailTextLabel.trailingAnchor),
            
            emailTextField.topAnchor.constraint(equalTo: instructionsEmailLabel.bottomAnchor, constant: 10),
            emailTextField.leadingAnchor.constraint(equalTo: emailTextLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: emailTextLabel.trailingAnchor),
            
            instructionsJoin.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 5),
            instructionsJoin.leadingAnchor.constraint(equalTo: emailTextLabel.leadingAnchor, constant: -5),
            instructionsJoin.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor, constant: 5),
            
            nextButton.topAnchor.constraint(equalTo: instructionsJoin.bottomAnchor, constant: 20),
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
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
       
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
        textField.backgroundColor = .secondarySystemGroupedBackground
        textField.borderStyle = .roundedRect
        textField.layer.borderColor = primaryColor.cgColor
        textField.layer.borderWidth = 2.0
        textFieldSelected = true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.backgroundColor = .tertiarySystemGroupedBackground
        textField.layer.borderColor = UIColor.systemBackground.cgColor
        textField.layer.borderWidth = 1.0
        textFieldSelected = false
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
             if (traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection)) {
                 // ColorUtils.loadCGColorFromAsset returns cgcolor for color name
                 emailTextField.layer.borderColor = textFieldSelected ? primaryColor.cgColor : UIColor.systemBackground.cgColor
             }
         }
    }
}

extension EmailRegistrationViewController: FormViewModel {
    func updateForm() {
        nextButton.configuration?.baseBackgroundColor = viewModel.buttonBackgroundColor
        nextButton.isUserInteractionEnabled = viewModel.formIsValid
    }
}

extension EmailRegistrationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        if URL.absoluteString == "presentCommunityInformation" {
            emailTextField.resignFirstResponder()
            whoCanJoinMenuLauncher.showImageSettings(in: view)
            return false
        }
        return true
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}

