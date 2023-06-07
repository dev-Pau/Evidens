//
//  WelcomeViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import Combine
import AuthenticationServices
import CryptoKit

private let onboardingMessageReuseIdentifier = "OnboardingMessageReuseIdentifier"
private let pagingSectionFooterViewReuseIdentifier = "PagingSectionFooterViewReuseIdentifier"
private let onboardingImageReuseIdentifier = "OnboardingImageReuseIdentifier"

class WelcomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let pagingInfoSubject = PassthroughSubject<PagingInfo, Never>()
    
    private var currentNonce: String?
    
    private var onboardingMessages = OnboardingMessage.getAllOnboardingMessages()
    private var onboardingImages = OnboardingImage.getAllOnboardingImages()
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        scrollView.isScrollEnabled = true
        scrollView.backgroundColor = .systemBackground
        return scrollView
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCellLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.bounces = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var imagesCollectionView: UICollectionView = {
        let layout = createCellImageLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isUserInteractionEnabled = false
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()

    private lazy var googleSingInButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = .quaternarySystemFill
        button.configuration?.background.strokeWidth = 1.5
         
        button.configuration?.image = UIImage(named: "google")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = .black
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .heavy)
        button.configuration?.attributedTitle = AttributedString("Continue with Google", attributes: container)
        
        button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    private lazy var appleSingInButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = .quaternarySystemFill
        button.configuration?.background.strokeWidth = 1.5
        
        button.configuration?.image = UIImage(systemName: "applelogo")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
        button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = .black
        button.configuration?.cornerStyle = .capsule
        
        button.addTarget(self, action: #selector(appleLoginButtonPressed), for: .touchUpInside)
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .heavy)
        button.configuration?.attributedTitle = AttributedString("Continue with Apple", attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
       
        button.configuration?.baseForegroundColor = primaryColor
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .bold)
        button.configuration?.attributedTitle = AttributedString("Log In", attributes: container)
        
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
        label.text = " OR "
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = .secondaryLabel
        label.backgroundColor = .systemBackground
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create account", for: .normal)
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
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = .secondaryLabel
        label.text = "Already a member?"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            self.navigationController?.navigationBar.isTranslucent = true
            self.navigationController?.navigationBar.tintColor = UIColor.white
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
        
        configureUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    //MARK: - Helpers
    func configureUI() {
        collectionView.register(OnboardingCell.self, forCellWithReuseIdentifier: onboardingMessageReuseIdentifier)
        collectionView.register(PagingSectionFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: pagingSectionFooterViewReuseIdentifier)
        imagesCollectionView.register(OnboardingImageCell.self, forCellWithReuseIdentifier: onboardingImageReuseIdentifier)
        
        view.addSubview(scrollView)
        view.backgroundColor = .systemBackground
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.delegate = self
        
        let stackLogin = UIStackView(arrangedSubviews: [haveAccountlabel, loginButton])
        stackLogin.translatesAutoresizingMaskIntoConstraints = false
        stackLogin.axis = .horizontal
        stackLogin.spacing = 0
       
        scrollView.addSubviews(collectionView, googleSingInButton, appleSingInButton, separatorView, orLabel, signUpButton, stackLogin, imagesCollectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: UIScreen.main.bounds.height * 0.1),
            collectionView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            collectionView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            collectionView.heightAnchor.constraint(equalToConstant: 120),
           
            googleSingInButton.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 100),
            googleSingInButton.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            googleSingInButton.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            googleSingInButton.heightAnchor.constraint(equalToConstant: 50),
            
            appleSingInButton.topAnchor.constraint(equalTo: googleSingInButton.bottomAnchor, constant: 10),
            appleSingInButton.leadingAnchor.constraint(equalTo: googleSingInButton.leadingAnchor),
            appleSingInButton.trailingAnchor.constraint(equalTo: googleSingInButton.trailingAnchor),
            appleSingInButton.heightAnchor.constraint(equalToConstant: 50),
            
            orLabel.topAnchor.constraint(equalTo: appleSingInButton.bottomAnchor, constant: 10),
            orLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            separatorView.centerYAnchor.constraint(equalTo: orLabel.centerYAnchor),
            separatorView.leadingAnchor.constraint(equalTo: appleSingInButton.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: appleSingInButton.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 0.4),
            
            signUpButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 10),
            signUpButton.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            stackLogin.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            stackLogin.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            
            imagesCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            imagesCollectionView.leadingAnchor.constraint(equalTo: collectionView.leadingAnchor),
            imagesCollectionView.trailingAnchor.constraint(equalTo: collectionView.trailingAnchor),
            imagesCollectionView.topAnchor.constraint(equalTo: stackLogin.bottomAnchor, constant: 30)
        ])
    }

    //MARK: - Handlers
    
    
    //MARK: - Actions
    
    @objc func loginButtonPressed() {
        let controller = LoginViewController()
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func signupButtonPressed() {
        let controller = EmailRegistrationViewController()
        
        let backItem = UIBarButtonItem()
        backItem.tintColor = .label
        backItem.title = ""
        
        navigationItem.backBarButtonItem = backItem
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func appleLoginButtonPressed() {
        startSignInWithAppleFlow()
    }
    
    @objc func googleLoginButtonPressed() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // Start the sign in flow!

        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [unowned self] signInResult, error in
          //
        //}
        //GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in

            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let signInResult = signInResult else { return }
            
            let user = signInResult.user
            
            guard let idToken = user.idToken?.tokenString else { return }
            //guard let authentication = signInResult?.user.authentication, let idToken = authentication.idToken else { return }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            //let credential = GoogleAuthProvider.credential(withIDToken: signInResult?.user.to, accessToken: <#T##String#>)

            // Firebase Auth
            
            
            
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                
                if let newUser = result?.additionalUserInfo?.isNewUser {
                    if newUser {

                        // Displaying user data
                        guard let googleUser = result?.user,
                              
                              let email = googleUser.email,
                            
                                let firstName = user.profile?.givenName/*user?.profile?.givenName*/else { return }

                        
                        var credentials = AuthCredentials(firstName: firstName, lastName: "", email: email, password: "", profileImageUrl: "", phase: .categoryPhase, category: .none, profession: "", speciality: "", interests: [])
                          
                        if let lastName = user.profile?.familyName {
                            credentials.lastName = lastName
                        }
                        
                        AuthService.registerGoogleUser(withCredential: credentials, withUid: googleUser.uid) { error in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            let controller = ContainerViewController()
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: false)
                        }
                    } else {
                        let controller = ContainerViewController()
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: false)
                    }
                }
            } 
        }
    }
}


extension WelcomeViewController {
    
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

extension WelcomeViewController: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
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
            
            Auth.auth().signIn(with: credential) { authResult, error in
                if (error != nil) { return }
                
                if let newUser = authResult?.additionalUserInfo?.isNewUser {
                    if newUser {
                        guard let appleUser = authResult?.user else { return }
                        
                        let credentials = AuthCredentials(firstName: firstName ?? "", lastName: lastName ?? "", email: email ?? "", password: "", profileImageUrl: "", phase: .categoryPhase, category: .none, profession: "", speciality: "", interests: [])
                        
                        
                        AuthService.registerAppleUser(withCredential: credentials, withUid: appleUser.uid) { error in
                            if let error = error {
                                print(error.localizedDescription)
                                return
                            }
                            let controller = ContainerViewController()
                            controller.modalPresentationStyle = .fullScreen
                            self.present(controller, animated: false)
                        }
                    } else {
                        let controller = ContainerViewController()
                        controller.modalPresentationStyle = .fullScreen
                        self.present(controller, animated: false)
                    }
                    
                }
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("error")
    }
}

extension WelcomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == imagesCollectionView {
            return onboardingImages.count
        } else {
            return onboardingMessages.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == imagesCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: onboardingImageReuseIdentifier, for: indexPath) as! OnboardingImageCell
            cell.set(image: onboardingImages[indexPath.row])
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: onboardingMessageReuseIdentifier, for: indexPath) as! OnboardingCell
            cell.set(message: onboardingMessages[indexPath.row])
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: pagingSectionFooterViewReuseIdentifier, for: indexPath) as! PagingSectionFooterView
        let itemCount = onboardingMessages.count
        footer.configure(with: itemCount)
        footer.subscribeTo(subject: pagingInfoSubject)
        footer.delegate = self
        return footer
    }
    
    
    private func createCellLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(100)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            
            let footer = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(20)), elementKind: UICollectionView.elementKindSectionFooter, alignment: .bottom)

            section.boundarySupplementaryItems = [footer]
            
            section.visibleItemsInvalidationHandler = { [weak self] (item, offset, env) -> Void in
                guard let self = self else { return }
                let page = round(offset.x / self.collectionView.bounds.width)
                // Send the page of the visible image to the PagingInfoSubject
                self.pagingInfoSubject.send(PagingInfo(currentPage: Int(page)))
                
            }
            return section
            
        }
        return layout
    }
    
    private func createCellImageLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(self.imagesCollectionView.frame.height)), subitems: [item])
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .paging
            return section
        }
        return layout
    }
}

extension WelcomeViewController: PagingSectionFooterViewDelegate {
    func messageDidChange(_ index: Int) {
        print(index)
        imagesCollectionView.scrollToItem(at: IndexPath(item: index, section: 0), at: .left, animated: true)
    }
}

