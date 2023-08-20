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

private let onboardingMessageReuseIdentifier = "OnboardingMessageReuseIdentifier"
private let pagingSectionFooterViewReuseIdentifier = "PagingSectionFooterViewReuseIdentifier"
private let onboardingImageReuseIdentifier = "OnboardingImageReuseIdentifier"

class OpeningViewController: UIViewController {
    
    //MARK: - Properties
    
    private var currentNonce: String?
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
    
    private lazy var googleSingInButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = separatorColor
        button.configuration?.background.strokeWidth = 0.4
         
        button.configuration?.image = UIImage(named: AppStrings.Assets.google)?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = .black
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .heavy)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Opening.googleSignIn, attributes: container)
        
        button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var appleSingInButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = separatorColor
        button.configuration?.background.strokeWidth = 0.4
        
        button.configuration?.image = UIImage(systemName: AppStrings.Icons.apple)?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
        button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = .black
        button.configuration?.cornerStyle = .capsule
        
        button.addTarget(self, action: #selector(appleLoginButtonPressed), for: .touchUpInside)
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .heavy)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Opening.appleSignIn, attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
       
        button.configuration?.baseForegroundColor = primaryColor
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .regular)
        button.configuration?.attributedTitle = AttributedString(AppStrings.Opening.logIn, attributes: container)
        
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = separatorColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = AppStrings.Opening.or
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(AppStrings.Opening.createAccount, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let haveAccountlabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .regular)
        label.textColor = .secondaryLabel
        label.text = AppStrings.Opening.member
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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

        addNavigationBarLogo(withTintColor: baseColor)
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
       
        scrollView.addSubviews(titleLabel, googleSingInButton, appleSingInButton, separatorView, orLabel, signUpButton, legalTextView, stackLogin)
        
        topLayoutConstraint = titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        bottomLayoutConstraint = stackLogin.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        
        NSLayoutConstraint.activate([
            topLayoutConstraint,
            titleLabel.bottomAnchor.constraint(equalTo: googleSingInButton.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            googleSingInButton.bottomAnchor.constraint(equalTo: appleSingInButton.topAnchor, constant: -10),
            googleSingInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            googleSingInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            googleSingInButton.heightAnchor.constraint(equalToConstant: 50),
            
            appleSingInButton.bottomAnchor.constraint(equalTo: orLabel.topAnchor, constant: -10),
            appleSingInButton.leadingAnchor.constraint(equalTo: googleSingInButton.leadingAnchor),
            appleSingInButton.trailingAnchor.constraint(equalTo: googleSingInButton.trailingAnchor),
            appleSingInButton.heightAnchor.constraint(equalToConstant: 50),
            
            orLabel.bottomAnchor.constraint(equalTo: signUpButton.topAnchor, constant: -15),
            orLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            orLabel.widthAnchor.constraint(equalToConstant: 40),
            
            separatorView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            separatorView.leadingAnchor.constraint(equalTo: appleSingInButton.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: appleSingInButton.trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            signUpButton.bottomAnchor.constraint(equalTo: legalTextView.topAnchor, constant: -10),
            signUpButton.leadingAnchor.constraint(equalTo: appleSingInButton.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: appleSingInButton.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            legalTextView.bottomAnchor.constraint(equalTo: stackLogin.topAnchor, constant: -130),
            legalTextView.leadingAnchor.constraint(equalTo: appleSingInButton.leadingAnchor),
            legalTextView.trailingAnchor.constraint(equalTo: appleSingInButton.trailingAnchor),
         
            bottomLayoutConstraint,
            stackLogin.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
        ])
        
        let privacyString = NSMutableAttributedString(string: AppStrings.Opening.legal)
        privacyString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 14, weight: .regular), range: NSRange(location: 0, length: privacyString.length))
        privacyString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.secondaryLabel, range: NSRange(location: 0, length: privacyString.length))

        let privacyRange = (privacyString.string as NSString).range(of: AppStrings.Legal.privacy)
        privacyString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.privacy, range: privacyRange)

        let termsRange = (privacyString.string as NSString).range(of: AppStrings.Legal.terms)
        privacyString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.terms, range: termsRange)

        let cookieRange = (privacyString.string as NSString).range(of: AppStrings.Legal.cookie)
        privacyString.addAttribute(NSAttributedString.Key.link, value: AppStrings.URL.cookie, range: cookieRange)

        legalTextView.delegate = self
        legalTextView.attributedText = privacyString
        
        titleLabel.layer.contentsGravity = .center
        scrollView.delegate = self
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
        // Get the Google client ID from FirebaseApp options
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Configure Google Sign-In with the obtained clientID
        let _ = GIDConfiguration(clientID: clientID)
        // Initiate Google Sign-In with a callback for the signInResult or error
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] signInResult, error in

            if let _ = error {
                // Handle error during Google Sign-In
                return
            }
            // Successfully signed in with Google
            guard let signInResult = signInResult else { return }
            let user = signInResult.user
            
            // Get the Google ID token and access token
            guard let idToken = user.idToken?.tokenString else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)

            // Sign in to Firebase with the Google credentials
            
            showProgressIndicator(in: view)
            
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                guard let strongSelf = self else { return }
                if let _ = error {
                    // Handle error during Firebase authentication
                    strongSelf.dismissProgressIndicator()
                    strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                    return
                }
                
                if let newUser = result?.additionalUserInfo?.isNewUser {
                    if newUser {
                        // New user registration
                        guard let googleUser = result?.user,
                                let email = googleUser.email,
                                let firstName = user.profile?.givenName else {
                            strongSelf.dismissProgressIndicator()
                            strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                            return
                            
                        }
                        
                        // Create AuthCredentials for new user
                        var credentials = AuthCredentials(email: email, phase: .category, uid: googleUser.uid)
                        
                        if let lastName = user.profile?.familyName {
                            credentials.set(lastName: lastName)
                        }
                        
                        credentials.set(firstName: firstName)
                        
                        // Register the new user in the database
                        AuthService.registerGoogleUser(withCredential: credentials) { [weak self] error in
                            guard let strongSelf = self else { return }
                            strongSelf.dismissProgressIndicator()
                            if let _ = error {
                                strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                            } else {
                                // Registration successful, present the main app screen
                                UserDefaults.logUserIn()
                                let controller = ContainerViewController()
                                controller.modalPresentationStyle = .fullScreen
                                strongSelf.present(controller, animated: false)

                            }
                        }
                    } else {
                        strongSelf.dismissProgressIndicator()
                        print("existing user")
                        UserDefaults.logUserIn()
                        // Existing user, present the main app screen
                        let controller = ContainerViewController()
                        controller.modalPresentationStyle = .fullScreen
                        strongSelf.present(controller, animated: false)

                    }
                }
            }
        }
    }
}

extension OpeningViewController {
    
    func startSignInWithAppleFlow() {
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

extension OpeningViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else { return }
            guard let appleIDToken = appleIDCredential.identityToken else { return }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else { return }
            
            let firstName = appleIDCredential.fullName?.givenName
            let lastName = appleIDCredential.fullName?.familyName
            let email = appleIDCredential.email
            
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)

            showProgressIndicator(in: view)
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if (error != nil) {
                    strongSelf.dismissProgressIndicator()
                    return
                }
                
                if let newUser = authResult?.additionalUserInfo?.isNewUser {
                    if newUser {
                        guard let appleUser = authResult?.user else { return }
                        
                        var credentials = AuthCredentials(phase: .category, uid: appleUser.uid)
                        
                        if let email = email {
                            credentials.set(email: email)
                        }
                        
                        if let firstName = firstName {
                            credentials.set(firstName: firstName)
                        }
                        
                        if let lastName = lastName {
                            credentials.set(lastName: lastName)
                        }
                        
                        AuthService.registerAppleUser(withCredential: credentials) { [weak self] error in
                            guard let strongSelf = self else { return }
                            strongSelf.dismissProgressIndicator()
                            
                            if let _ = error {
                                strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                                return
                            }
                            UserDefaults.logUserIn()
                            let controller = ContainerViewController()
                            controller.modalPresentationStyle = .fullScreen
                            strongSelf.present(controller, animated: false)
                        }
                    } else {
                        strongSelf.dismissProgressIndicator()
                        UserDefaults.logUserIn()
                        let controller = ContainerViewController()
                        controller.modalPresentationStyle = .fullScreen
                        strongSelf.present(controller, animated: false)
                    }
                }
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

extension OpeningViewController: UITextViewDelegate {
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


