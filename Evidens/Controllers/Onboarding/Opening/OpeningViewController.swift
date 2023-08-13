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
        button.configuration?.background.strokeWidth = 1
         
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
        button.configuration?.background.strokeWidth = 1
        
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
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureUI()
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
       
        scrollView.addSubviews(titleLabel, googleSingInButton, appleSingInButton, separatorView, orLabel, signUpButton, stackLogin)
        
        NSLayoutConstraint.activate([
            titleLabel.bottomAnchor.constraint(equalTo: googleSingInButton.topAnchor, constant: -60),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            googleSingInButton.topAnchor.constraint(equalTo: scrollView.centerYAnchor, constant: -100),
            googleSingInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            googleSingInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            googleSingInButton.heightAnchor.constraint(equalToConstant: 50),
            
            appleSingInButton.topAnchor.constraint(equalTo: googleSingInButton.bottomAnchor, constant: 10),
            appleSingInButton.leadingAnchor.constraint(equalTo: googleSingInButton.leadingAnchor),
            appleSingInButton.trailingAnchor.constraint(equalTo: googleSingInButton.trailingAnchor),
            appleSingInButton.heightAnchor.constraint(equalToConstant: 50),
            
            orLabel.topAnchor.constraint(equalTo: appleSingInButton.bottomAnchor, constant: 15),
            orLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            orLabel.widthAnchor.constraint(equalToConstant: 40),
            
            separatorView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            separatorView.leadingAnchor.constraint(equalTo: appleSingInButton.leadingAnchor, constant: 10),
            separatorView.trailingAnchor.constraint(equalTo: appleSingInButton.trailingAnchor, constant: -10),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            signUpButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 15),
            signUpButton.leadingAnchor.constraint(equalTo: appleSingInButton.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: appleSingInButton.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            stackLogin.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            stackLogin.leadingAnchor.constraint(equalTo: signUpButton.leadingAnchor),
        ])
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
            
            Auth.auth().signIn(with: credential) { [weak self] authResult, error in
                guard let strongSelf = self else { return }
                if (error != nil) { return }
                
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
                            if let _ = error {
                                strongSelf.displayAlert(withTitle: AppStrings.Error.title, withMessage: AppStrings.Error.unknown)
                                return
                            }
                            let controller = ContainerViewController()
                            controller.modalPresentationStyle = .fullScreen
                            strongSelf.present(controller, animated: false)
                        }
                    } else {
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
