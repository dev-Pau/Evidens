//
//  EmailRegistrationViewControllerl.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 13/7/22.
//

import UIKit

class EmailRegistrationViewController: UIViewController {
    
    private var viewModel = EmailRegistrationViewModel()
    private var whoCanJoinMenuLauncher = ContextMenu(menuLauncherData: Display(content: .join))
    
    private var textFieldSelected: Bool = false
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false
        scrollView.keyboardDismissMode = .none
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()

    private let emailTextField: UITextField = {
        let tf = InputTextField(placeholder: AppStrings.Opening.logInEmailPlaceholder, secureTextEntry: false, title: AppStrings.Opening.logInEmailPlaceholder)
        tf.keyboardType = .emailAddress
        tf.autocapitalizationType = .none
        return tf
    }()
    
    private let emailTextLabel: UILabel = {
        let label = CustomLabel(placeholder: AppStrings.Opening.registerEmailTitle)
        return label
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.baseBackgroundColor = primaryColor
        config.baseForegroundColor = .white
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .medium)
        
        config.attributedTitle = AttributedString(AppStrings.Miscellaneous.next, attributes: container)
        config.cornerStyle = .capsule
        button.configuration = config
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let legalTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: primaryColor]
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    private var nextToolbarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnViewTap()
        configureNavigationBar()
        configureUI()
        configureNotificationObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emailTextField.becomeFirstResponder()
    }
    
    private func configureNavigationBar() {

    }

    
    private func configureNotificationObservers() {
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailTextField.delegate = self
    }
    
    private func configureUI() {
        view.backgroundColor = .systemBackground
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
        
        scrollView.addSubviews(emailTextLabel, emailTextField, legalTextView)
        
        NSLayoutConstraint.activate([
            emailTextLabel.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            emailTextLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailTextLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            emailTextField.topAnchor.constraint(equalTo: emailTextLabel.bottomAnchor, constant: 40),
            emailTextField.leadingAnchor.constraint(equalTo: emailTextLabel.leadingAnchor),
            emailTextField.trailingAnchor.constraint(equalTo: emailTextLabel.trailingAnchor),
            
            legalTextView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            legalTextView.leadingAnchor.constraint(equalTo: emailTextLabel.leadingAnchor, constant: -5),
            legalTextView.trailingAnchor.constraint(equalTo: emailTextField.trailingAnchor, constant: 5),
            
        ])
        
        let privacyAttributedString = NSMutableAttributedString(string: AppStrings.Opening.legal)
        privacyAttributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .regular), range: NSRange(location: 0, length: privacyAttributedString.length))
        privacyAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: privacyAttributedString.length))

        let privacyRange = (privacyAttributedString.string as NSString).range(of: AppStrings.Legal.privacy)
        privacyAttributedString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.privacy, range: privacyRange)

        let termsRange = (privacyAttributedString.string as NSString).range(of: AppStrings.Legal.terms)
        privacyAttributedString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.terms, range: termsRange)

        let cookieRange = (privacyAttributedString.string as NSString).range(of: AppStrings.Legal.cookie)
        privacyAttributedString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.cookie, range: cookieRange)

        legalTextView.delegate = self
        legalTextView.attributedText = privacyAttributedString
        let appearance = UIToolbarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.shadowImage = nil
        appearance.shadowColor = .clear
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        toolbar.standardAppearance = appearance
        toolbar.scrollEdgeAppearance = appearance
        toolbar.sizeToFit()
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        nextToolbarButton = UIBarButtonItem(customView: nextButton)
        toolbar.items = [flexibleSpace, nextToolbarButton]
        emailTextField.inputAccessoryView = toolbar
        nextToolbarButton.isEnabled = false
    }
    
    @objc func didTapBack() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    @objc func handleNext() {
        guard let email = emailTextField.text else { return }
        AuthService.userExists(withEmail: email) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                let controller = PasswordRegistrationViewController(email: email)
                strongSelf.emailTextField.resignFirstResponder()
                strongSelf.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    @objc func textDidChange() {
        viewModel.email = emailTextField.text
        updateForm()
    }
}

extension EmailRegistrationViewController: UITextFieldDelegate {
    
}

extension EmailRegistrationViewController: FormViewModel {
    func updateForm() {
        nextToolbarButton.isEnabled = viewModel.emailIsEmpty
    }
}

extension EmailRegistrationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let urlString = url.absoluteString
        if urlString == AppStrings.URL.privacy {
            if let privacyURL = URL(string: AppStrings.URL.privacy) {
                if UIApplication.shared.canOpenURL(privacyURL) {
                    presentSafariViewController(withURL: privacyURL)
                } else {
                    presentWebViewController(withURL: privacyURL)
                }
            }
            return false
        } else if urlString == AppStrings.URL.terms {
            if let termsURL = URL(string: AppStrings.URL.terms) {
                if UIApplication.shared.canOpenURL(termsURL) {
                    presentSafariViewController(withURL: termsURL)
                } else {
                    presentWebViewController(withURL: termsURL)
                }
            }
            return false
        } else if urlString == AppStrings.URL.cookie {
            if let cookieURL = URL(string: AppStrings.URL.cookie) {
                if UIApplication.shared.canOpenURL(cookieURL) {
                    presentSafariViewController(withURL: cookieURL)
                } else {
                    presentWebViewController(withURL: cookieURL)
                }
            }
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

