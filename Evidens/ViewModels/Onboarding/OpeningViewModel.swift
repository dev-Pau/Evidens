//
//  OpeningViewModel.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 28/9/23.
//

import UIKit
import Firebase
import CryptoKit
import GoogleSignIn
import GoogleSignInSwift
import AuthenticationServices

/// The viewModel for a Opening.
class OpeningViewModel {
    
    private(set) var currentNonce: String?
    
    func randomNonceString(length: Int = 32) -> String {
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
    
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
    
    func signInWithGoogle(presentingOn viewController: UIViewController, completion: @escaping(LogInError?) -> Void) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let _ = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(withPresenting: viewController) { [unowned self] signInResult, error in
            
            if let _ = error {
                return
            }
            
            guard let signInResult = signInResult else { return }
            
            let user = signInResult.user

            guard let idToken = user.idToken?.tokenString else { return }

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: user.accessToken.tokenString)
            
            viewController.showProgressIndicator(in: viewController.view)
            
            Auth.auth().signIn(with: credential) { [weak self] result, error in
                guard let _ = self else { return }
                if let _ = error {
                    completion(.unknown)
                    return
                }
                
                if let newUser = result?.additionalUserInfo?.isNewUser {
                    if newUser {

                        guard let googleUser = result?.user,
                                let email = googleUser.email,
                                let firstName = user.profile?.givenName else {
                            completion(.unknown)
                            return
                            
                        }

                        var credentials = AuthCredentials(email: email, phase: .category, uid: googleUser.uid)
                        
                        if let lastName = user.profile?.familyName {
                            credentials.set(lastName: lastName)
                        }
                        
                        credentials.set(firstName: firstName)

                        AuthService.registerGoogleUser(withCredential: credentials) { [weak self] error in
                            guard let _ = self else { return }
                            if let _ = error {
                                completion(.unknown)
                            } else {
                                
                                UserDefaults.logUserIn()
                                completion(nil)
                            }
                        }
                    } else {
                        UserDefaults.logUserIn()
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func signInWithApple(authorization: ASAuthorization, presentingOn viewController: UIViewController, completion: @escaping(LogInError?) -> Void) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            completion(.unknown)
            return
        }
        
        guard let nonce = currentNonce, let appleIDToken = appleIDCredential.identityToken, let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
            completion(.unknown)
            return
        }
        
        let firstName = appleIDCredential.fullName?.givenName
        let lastName = appleIDCredential.fullName?.familyName
        let email = appleIDCredential.email
        
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        
        viewController.showProgressIndicator(in: viewController.view)
        
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let _ = self else { return }
            
            if (error != nil) {
                completion(.unknown)
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
                        guard let _ = self else { return }
                        
                        if let _ = error {
                            completion(.unknown)
                            return
                        }
                        
                        UserDefaults.logUserIn()
                        completion(nil)
                    }
                } else {
                    UserDefaults.logUserIn()
                    completion(nil)
                }
            }
        }
    }
    
    func edit(currentNonce: String?) {
        self.currentNonce = currentNonce
    }
}
