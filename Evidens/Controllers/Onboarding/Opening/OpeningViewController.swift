//
//  OpeningViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import AuthenticationServices
import CryptoKit

class OpeningViewController: UIViewController {
    
    //MARK: - Properties
    
    private var viewModel = OpeningViewModel()

    private var bottomLayoutConstraint: NSLayoutConstraint!
    private var topLayoutConstraint: NSLayoutConstraint!
    private var offset: CGFloat?
    private var firstOffset: Bool = true
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private var titleLabel: PrimaryLabel!
   
    private lazy var googleSignInButton: LoginButton = {
        let button = LoginButton(kind: .google)
        button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var appleSignInButton: LoginButton = {
        let button = LoginButton(kind: .apple)
        button.addTarget(self, action: #selector(appleLoginButtonPressed), for: .touchUpInside)
        return button
    }()
   
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.tintAdjustmentMode = .normal
        button.configuration = .plain()
        
        button.configuration?.baseForegroundColor = K.Colors.primaryColor
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15.0, scaleStyle: .largeTitle, weight: .regular)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Opening.logIn, attributes: container)
        
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = K.Colors.separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Opening.or
        label.font = UIFont.addFont(size: 12, scaleStyle: .largeTitle, weight: .medium)
        label.textColor = K.Colors.primaryGray
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        var configuration = UIButton.Configuration.filled()
        button.tintAdjustmentMode = .normal
        configuration.baseForegroundColor = .white
        configuration.baseBackgroundColor = K.Colors.primaryColor
        configuration.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont.addFont(size: 15, scaleStyle: .body, weight: .heavy, scales: false)
        configuration.attributedTitle = AttributedString(AppStrings.Opening.createAccount, attributes: container)

        button.configuration = configuration
        button.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let haveAccountlabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.addFont(size: 15, scaleStyle: .largeTitle, weight: .regular)
        label.textColor = K.Colors.primaryGray
        label.text = AppStrings.Opening.member
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let legalTextView: UITextView = {
        let tv = UITextView()
        tv.linkTextAttributes = [NSAttributedString.Key.foregroundColor: K.Colors.primaryColor]
        tv.isSelectable = true
        tv.isUserInteractionEnabled = true
        tv.isEditable = false
        tv.delaysContentTouches = false
        tv.isScrollEnabled = false
        tv.translatesAutoresizingMaskIntoConstraints = false
        return tv
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
    }
    
    override func viewDidLayoutSubviews() {
        if firstOffset {
            offset = getBaseContentOffset()
            firstOffset.toggle()
        }
    }
    
    //MARK: - Helpers
    
    private func configureNavigationBar() {

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.setBackIndicatorImage(UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label), transitionMaskImage: UIImage(systemName: AppStrings.Icons.backArrow, withConfiguration: UIImage.SymbolConfiguration(weight: .semibold))?.withRenderingMode(.alwaysOriginal).withTintColor(.label))
        
        let barButtonItemAppearance = UIBarButtonItemAppearance()
        barButtonItemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.clear]
        appearance.backButtonAppearance = barButtonItemAppearance

        appearance.shadowImage = nil
        appearance.shadowColor = .clear

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance

        addNavigationBarLogo(withTintColor: K.Colors.primaryColor)
    }
    
    private func configureUI() {
        view.addSubview(scrollView)
        view.backgroundColor = .systemBackground
        
        scrollView.frame = view.bounds

        titleLabel = PrimaryLabel(placeholder: AppStrings.Opening.phrase)
        let stackLogin = UIStackView(arrangedSubviews: [haveAccountlabel, loginButton])
        stackLogin.translatesAutoresizingMaskIntoConstraints = false
        stackLogin.axis = .horizontal
        stackLogin.spacing = 0
       
        scrollView.addSubviews(titleLabel, googleSignInButton, appleSignInButton, separatorView, orLabel, signUpButton, legalTextView, stackLogin)
        
        topLayoutConstraint = titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        bottomLayoutConstraint = stackLogin.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            topLayoutConstraint,
            titleLabel.bottomAnchor.constraint(equalTo: googleSignInButton.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewModel.padding),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -viewModel.padding),
            
            googleSignInButton.bottomAnchor.constraint(equalTo: appleSignInButton.topAnchor, constant: -10),
            googleSignInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: viewModel.padding),
            googleSignInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -viewModel.padding),
            googleSignInButton.heightAnchor.constraint(equalToConstant: viewModel.buttonSize),
            
            appleSignInButton.bottomAnchor.constraint(equalTo: orLabel.topAnchor, constant: -15),
            appleSignInButton.leadingAnchor.constraint(equalTo: googleSignInButton.leadingAnchor),
            appleSignInButton.trailingAnchor.constraint(equalTo: googleSignInButton.trailingAnchor),
            appleSignInButton.heightAnchor.constraint(equalToConstant: viewModel.buttonSize),
            
            orLabel.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -15),
            orLabel.centerXAnchor.constraint(equalTo: appleSignInButton.centerXAnchor),
            orLabel.widthAnchor.constraint(equalToConstant: 40),
            
            separatorView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            separatorView.leadingAnchor.constraint(equalTo: appleSignInButton.leadingAnchor, constant: viewModel.linePadding),
            separatorView.trailingAnchor.constraint(equalTo: appleSignInButton.trailingAnchor, constant: -viewModel.linePadding),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            signUpButton.bottomAnchor.constraint(equalTo: legalTextView.topAnchor, constant: -10),
            signUpButton.leadingAnchor.constraint(equalTo: appleSignInButton.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: appleSignInButton.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: viewModel.buttonSize),
            
            legalTextView.bottomAnchor.constraint(equalTo: stackLogin.topAnchor, constant: -40),
            legalTextView.leadingAnchor.constraint(equalTo: appleSignInButton.leadingAnchor),
            legalTextView.trailingAnchor.constraint(equalTo: appleSignInButton.trailingAnchor),
         
            bottomLayoutConstraint,
            stackLogin.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
        ])
        
        let privacyString = NSMutableAttributedString(string: AppStrings.Opening.legal)
        privacyString.addAttribute(NSAttributedString.Key.font, value: UIFont.addFont(size: 15.0, scaleStyle: .largeTitle, weight: .regular), range: NSRange(location: 0, length: privacyString.length))
        privacyString.addAttribute(NSAttributedString.Key.foregroundColor, value: K.Colors.primaryGray, range: NSRange(location: 0, length: privacyString.length))

        let privacyRange = (privacyString.string as NSString).range(of: AppStrings.Legal.privacy)
        privacyString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.privacy, range: privacyRange)

        let termsRange = (privacyString.string as NSString).range(of: AppStrings.Legal.terms)
        privacyString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.terms, range: termsRange)

        legalTextView.delegate = self
        legalTextView.attributedText = privacyString
        titleLabel.layer.contentsGravity = .center
        scrollView.delegate = self
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if #available(iOS 13.0, *) {
            if (traitCollection.preferredContentSizeCategory != previousTraitCollection?.preferredContentSizeCategory) {
                guard let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate else {
                    return
                }

                sceneDelegate.updateViewController(ContainerViewController(withLoadingView: true))
            }
        }
    }

    //MARK: - Actions
    
    @objc func loginButtonPressed() {
        let controller = LoginEmailViewController()
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func signupButtonPressed() {
        let controller = EmailRegistrationViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func appleLoginButtonPressed() {
        startSignInWithAppleFlow()
    }
    
    @objc func googleLoginButtonPressed() {
        viewModel.signInWithGoogle(presentingOn: self) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.dismissProgressIndicator()
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                let controller = ContainerViewController()
                controller.modalPresentationStyle = .fullScreen
                strongSelf.present(controller, animated: false)
            }
        }
    }
}

extension OpeningViewController {
    
    func startSignInWithAppleFlow() {
        viewModel.edit(currentNonce: viewModel.randomNonceString())
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        guard let currentNonce = viewModel.currentNonce else { return }
        request.nonce = viewModel.sha256(currentNonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
}

extension OpeningViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        viewModel.signInWithApple(authorization: authorization, presentingOn: self) { [weak self] error in
            guard let strongSelf = self else { return }
            if let error {
                strongSelf.dismissProgressIndicator()
                strongSelf.displayAlert(withTitle: error.title, withMessage: error.content)
            } else {
                let controller = ContainerViewController()
                controller.modalPresentationStyle = .fullScreen
                strongSelf.present(controller, animated: false)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        return
    }
}

//MARK: - LoginEmailViewControllerDelegate

extension OpeningViewController: LoginEmailViewControllerDelegate {
    func didTapForgotPassword() {
        let controller = ResetPasswordViewController()
        controller.delegate = self
        
        let navigationController = UINavigationController(rootViewController: controller)
        navigationController.modalPresentationStyle = .fullScreen
        
        present(navigationController, animated: true)
    }
}

//MARK: - ResetPasswordViewControllerDelegate

extension OpeningViewController: ResetPasswordViewControllerDelegate {
    func controllerDidSendResetPassword(_ controller: ResetPasswordViewController) {
        navigationController?.popViewController(animated: true)
        displayAlert(withTitle: AppStrings.Alerts.Title.resetPassword, withMessage: AppStrings.Alerts.Subtitle.resetPassword)
    }
}

//MARK: - UIScrollViewDelegate

extension OpeningViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let offset {
            let constant = -(scrollView.contentOffset.y - offset)
            topLayoutConstraint.constant = constant
            bottomLayoutConstraint.constant = constant
            view.layoutIfNeeded()
        }
    }
    
    func getBaseContentOffset() -> CGFloat {
        return scrollView.contentOffset.y
    }
}

//MARK: - UITextViewDelegate

extension OpeningViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith url: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
    
        #if DEBUG
        if let privacyURL = URL(string: AppStrings.URL.draftPrivacy) {
            if UIApplication.shared.canOpenURL(privacyURL) {
                presentSafariViewController(withURL: privacyURL)
            }
        }
        return false
        #else
        if let privacyURL = URL(string: AppStrings.URL.draftPrivacy) {
            if UIApplication.shared.canOpenURL(privacyURL) {
                presentSafariViewController(withURL: privacyURL)
            }
        }
        return false
        #endif
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        if textView.selectedTextRange != nil {
            textView.delegate = nil
            textView.selectedTextRange = nil
            textView.delegate = self
        }
    }
}


