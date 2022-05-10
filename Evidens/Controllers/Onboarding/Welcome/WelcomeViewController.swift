//
//  WelcomeViewController.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 2/10/21.
//

import UIKit
import Firebase
import GoogleSignIn
import RealmSwift


class WelcomeViewController: UIViewController {
    
    //MARK: - Properties
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private let welcomeText: UILabel = {
        let label = CustomLabel(placeholder: "Welcome to the healthcare community.")
        return label
    }()
    
    private let googleSingInButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = UIColor(rgb: 0xDCE4EA)
        button.configuration?.background.strokeWidth = 1.5
        
        
        button.configuration?.image = UIImage(named: "google")?.scalePreservingAspectRatio(targetSize: CGSize(width: 20, height: 20))
        button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = UIColor(rgb: 0x2B2D42)
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont(name: "Raleway-ExtraBold", size: 15)
        button.configuration?.attributedTitle = AttributedString("Continue with Google", attributes: container)
        
        button.addTarget(self, action: #selector(googleLoginButtonPressed), for: .touchUpInside)
        
        return button
    }()
    
    
    private let appleSingInButton: UIButton = {
        let button = UIButton()
        button.configuration = .filled()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.background.strokeColor = UIColor(rgb: 0xDCE4EA)
        button.configuration?.background.strokeWidth = 1.5
        
        
        button.configuration?.image = UIImage(systemName: "applelogo")?.scalePreservingAspectRatio(targetSize: CGSize(width: 25, height: 25))
        button.configuration?.imagePadding = 15
        
        button.configuration?.baseForegroundColor = UIColor(rgb: 0x2B2D42)
        button.configuration?.cornerStyle = .capsule
        
        var container = AttributeContainer()
        container.font = UIFont(name: "Raleway-ExtraBold", size: 15)
        button.configuration?.attributedTitle = AttributedString("Continue with Apple", attributes: container)
        
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.configuration = .plain()
        button.configuration?.baseBackgroundColor = .white
        
        button.configuration?.baseForegroundColor = UIColor(rgb: 0x5ABBB7)
        
        var container = AttributeContainer()
        container.font = UIFont(name: "Raleway-Bold", size: 13)
        button.configuration?.attributedTitle = AttributedString("Log In", attributes: container)
        
        button.addTarget(self, action: #selector(loginButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let separatorLabel: UILabel = {
        let label = UILabel()
        label.setDimensions(height: 1, width: 310)
        label.backgroundColor = UIColor(rgb: 0xDCE4EA)
        return label
    }()
    
    private let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(rgb: 0x5ABBB7)
        button.setHeight(50)
        button.layer.cornerRadius = 26
        button.titleLabel?.font = UIFont(name: "Raleway-ExtraBold", size: 18)
        button.addTarget(self, action: #selector(signupButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private let haveAccountlabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Raleway-Regular", size: 13)
        label.text = "Have an account already?"
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
    
    
    //MARK: - Helpers
    func configureUI() {
        view.addSubview(scrollView)
        view.backgroundColor = .white
        
        scrollView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - 1.75 * topbarHeight)
        
        navigationController?.navigationBar.isHidden = true
        
        navigationController?.navigationBar.barStyle = .black
        
        scrollView.addSubview(welcomeText)
        welcomeText.anchor(top: scrollView.topAnchor, paddingTop: 200)
        welcomeText.centerX(inView: scrollView)
        welcomeText.setWidth(UIScreen.main.bounds.width * 0.8)
        
        scrollView.addSubview(googleSingInButton)
        googleSingInButton.anchor(top: welcomeText.bottomAnchor, paddingTop: 60)
        googleSingInButton.centerX(inView: scrollView)
        googleSingInButton.setHeight(50)
        googleSingInButton.setWidth(UIScreen.main.bounds.width * 0.8)
        
        scrollView.addSubview(appleSingInButton)
        appleSingInButton.anchor(top: googleSingInButton.bottomAnchor, paddingTop: 6)
        appleSingInButton.centerX(inView: scrollView)
        appleSingInButton.setHeight(50)
        appleSingInButton.setWidth(UIScreen.main.bounds.width * 0.8)
        
        scrollView.addSubview(separatorLabel)
        separatorLabel.anchor(top: appleSingInButton.bottomAnchor, paddingTop: 10)
        separatorLabel.centerX(inView: scrollView)
        
        scrollView.addSubview(signUpButton)
        signUpButton.anchor(top: separatorLabel.bottomAnchor, paddingTop: 10)
        signUpButton.centerX(inView: scrollView)
        signUpButton.setHeight(50)
        signUpButton.setWidth(UIScreen.main.bounds.width * 0.8)
        
        let stackLogin = UIStackView(arrangedSubviews: [haveAccountlabel, loginButton])
        stackLogin.axis = .horizontal
        stackLogin.spacing = 0
        
        scrollView.addSubview(stackLogin)
        stackLogin.centerX(inView: scrollView)
        stackLogin.anchor(top: signUpButton.bottomAnchor, paddingTop: 20)
    }
    
    //MARK: - Handlers
    
    
    //MARK: - Actions
    @objc func loginButtonPressed() {
        let controller = LoginViewController()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func signupButtonPressed() {
        let controller = RegistrationViewController()
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
                print(googleUser.email)
                
            }
        }
    }
}

extension WelcomeViewController {
    //Get height of status bar + navigation bar
    var topbarHeight: CGFloat {
        return (view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0.0) +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
    }
}

