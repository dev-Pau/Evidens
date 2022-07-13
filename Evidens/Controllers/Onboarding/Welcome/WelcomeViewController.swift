//
//  WelcomeViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/21.
//

import UIKit
import Firebase
import GoogleSignIn

class WelcomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        scrollView.showsVerticalScrollIndicator = false
        scrollView.bounces = true
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private let welcomeText: UILabel = {
        let label = CustomLabel(placeholder: "Welcome to the healthcare community.")
        return label
    }()
    
    private lazy var googleSingInButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = lightGrayColor
        button.configuration?.background.strokeWidth = 1.5
         
        button.configuration?.image = UIImage(named: "google")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = blackColor
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .heavy)
        button.configuration?.attributedTitle = AttributedString("Continue with Google", attributes: container)
        
        button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    
    private let appleSingInButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = lightGrayColor
        button.configuration?.background.strokeWidth = 1.5
        
        button.configuration?.image = UIImage(systemName: "applelogo")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
        button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = blackColor
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = .systemFont(ofSize: 15, weight: .heavy)
        button.configuration?.attributedTitle = AttributedString("Continue with Apple", attributes: container)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.baseBackgroundColor = .white
        
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
        view.backgroundColor = lightGrayColor
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let orLabel: UILabel = {
        let label = UILabel()
        label.text = " OR "
        label.font = .systemFont(ofSize: 12, weight: .semibold)
        label.textColor = grayColor
        label.backgroundColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = primaryColor
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private let haveAccountlabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .semibold)
        label.textColor = grayColor
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
            self.navigationController?.navigationBar.isTranslucent = true  // pass "true" for fixing iOS 15.0 black bg issue
            self.navigationController?.navigationBar.tintColor = UIColor.white // We need to set tintcolor for iOS 15.0
            appearance.shadowColor = .clear    //removing navigationbar 1 px bottom border.
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
        view.addSubview(scrollView)
        view.backgroundColor = .white
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
      
        navigationController?.navigationBar.barStyle = .black
        
        let stackLogin = UIStackView(arrangedSubviews: [haveAccountlabel, loginButton])
        stackLogin.translatesAutoresizingMaskIntoConstraints = false
        stackLogin.axis = .horizontal
        stackLogin.spacing = 0
       
        scrollView.addSubviews(welcomeText, googleSingInButton, appleSingInButton, separatorView, orLabel, signUpButton, stackLogin)
        
        NSLayoutConstraint.activate([
            welcomeText.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: UIScreen.main.bounds.height * 0.2),
            welcomeText.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor),
            welcomeText.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width * 0.8),
            
            googleSingInButton.topAnchor.constraint(equalTo: welcomeText.bottomAnchor, constant: 60),
            googleSingInButton.leadingAnchor.constraint(equalTo: welcomeText.leadingAnchor),
            googleSingInButton.trailingAnchor.constraint(equalTo: welcomeText.trailingAnchor),
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
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            signUpButton.topAnchor.constraint(equalTo: orLabel.bottomAnchor, constant: 10),
            signUpButton.leadingAnchor.constraint(equalTo: separatorView.leadingAnchor),
            signUpButton.trailingAnchor.constraint(equalTo: separatorView.trailingAnchor),
            signUpButton.heightAnchor.constraint(equalToConstant: 50),
            
            stackLogin.topAnchor.constraint(equalTo: signUpButton.bottomAnchor, constant: 20),
            stackLogin.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor)
        ])
    }
    
    //MARK: - Handlers
    
    
    //MARK: - Actions
    @objc func loginButtonPressed() {
        let controller = LoginViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func signupButtonPressed() {
        let controller = EmailRegistrationViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func googleLoginButtonPressed() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        // Create Google Sign In configuration object.
        let config = GIDConfiguration(clientID: clientID)
        // Start the sign in flow!
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)

            // Firebase Auth
            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }

                // Displaying user data
                guard let googleUser = result?.user else { return }
                
                print(googleUser.displayName ?? "Success!")
                print(googleUser.email ?? "No email")
                
            }
        }
    }
}

