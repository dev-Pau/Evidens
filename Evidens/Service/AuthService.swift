//
//  AuthService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import GoogleSignIn

/// A authentication service used to interface with FirebaseAuth.
struct AuthService {

    /// Logs in a user with the provided email and password credentials in Firebase.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - completion: A closure to be called when the login process is completed. It takes two optional parameters: an `AuthDataResult` object containing information about the authenticated user, or `nil` if the login was unsuccessful, and an `Error` object if an error occurred during the login process.
    static func logUserIn(withEmail email: String, password: String, completion: @escaping(Result<AuthDataResult, LogInError>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                let nsError = error as NSError
                let errCode = AuthErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .wrongPassword:
                    completion(.failure(.wrongPassword))
                case .tooManyRequests:
                    completion(.failure(.tooManyRequests))
                case .networkError:
                    completion(.failure(.network))
                default:
                    completion(.failure(.unknown))
                }
            } else {
                if let authResult {
                    UserDefaults.logUserIn()
                    completion(.success(authResult))

                } else {
                    completion(.failure(.unknown))
                }
            }
        }
    }
    
    /// Registers a new user with the provided credentials in Firebase.
    ///
    /// - Parameters:
    ///   - credentials: The authentication credentials for the user.
    ///   - completion: A closure to be called when the registration process is completed. It takes an optional `Error` parameter, which will be `nil` if the registration was successful, or an `Error` object if an error occurred during the registration process.
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(SignUpError?) -> Void) {
        guard let password = credentials.password, let email = credentials.email else { return }
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                let nsError = error as NSError
                let errorCode = AuthErrorCode(_nsError: nsError)
                
                switch errorCode.code {
                case .networkError:
                    completion(.network)
                case .weakPassword:
                    completion(.weakPassword)
                default:
                    completion(.unknown)
                }
            } else {
                guard let uid = result?.user.uid else {
                    completion(.unknown)
                    return
                }
                
                let authUser: [String: Any] = ["email": email,
                                               "uid": uid,
                                               "phase": credentials.phase.rawValue
                ]
                
                UserDefaults.standard.set(uid, forKey: "uid")
                COLLECTION_USERS.document(uid).setData(authUser) { error in
                    if let _ = error {
                        completion(.unknown)
                    } else {
                        completion(nil)
                        setUserHistory(for: .phase, with: credentials.phase.rawValue)
                    }
                }
            }
        }
    }
    
    /// Registers a new user with the provided Google credentials and user UID in Firebase.
    ///
    /// - Parameters:
    ///   - credentials: The authentication credentials for the user obtained from Google Sign-In.
    ///   - uid: The unique identifier (UID) of the user.
    ///   - completion: A closure to be called when the registration process is completed. It takes an optional `Error` parameter, which will be `nil` if the registration was successful, or an `Error` object if an error occurred during the registration process.
    static func registerGoogleUser(withCredential credentials: AuthCredentials, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        guard let firstName = credentials.firstName, let uid = credentials.uid, let email = credentials.email else {
            completion(.unknown)
            return
        }
        
        var googleUser: [String: Any] = ["firstName": firstName.capitalized,
                                         "email": email,
                                         "uid": uid,
                                         "phase": credentials.phase.rawValue
        ]
        
        if let lastName = credentials.lastName {
            googleUser["lastName"] = lastName.capitalized
        }
        
        UserDefaults.standard.set(uid, forKey: "uid")
        
        COLLECTION_USERS.document(uid).setData(googleUser) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
            } else {
                completion(nil)
                setUserHistory(for: .phase, with: credentials.phase.rawValue)
            }
        }
    }
    
    /// Registers a new user with the provided Apple credentials and user UID in Firebase.
    ///
    /// - Parameters:
    ///   - credentials: The authentication credentials for the user obtained from Apple Sign-In.
    ///   - uid: The unique identifier (UID) of the user.
    ///   - completion: A closure to be called when the registration process is completed. It takes an optional `Error` parameter, which will be `nil` if the registration was successful, or an `Error` object if an error occurred during the registration process.
    static func registerAppleUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        guard let uid = credentials.uid else { return }
        
        var appleUser: [String: Any] = [
            "uid": uid,
            "phase": credentials.phase.rawValue,
        ]
        
        
        if let firstName = credentials.firstName {
            appleUser["firstName"] = firstName.capitalized
        }
        
        if let lastName = credentials.lastName {
            appleUser["lastName"] = lastName.capitalized
        }
        
        if let email = credentials.email {
            appleUser["email"] = email
        }
        
        UserDefaults.standard.set(uid, forKey: "uid")
        
        COLLECTION_USERS.document(uid).setData(appleUser) { error in
            if let error {
                completion(error)
            } else {
                completion(nil)
                setUserHistory(for: .phase, with: credentials.phase.rawValue)
            }
        }
    }
    
    /// Updates the profession category details of a user in Firebase.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier (UID) of the user.
    ///   - credentials: The updated authentication credentials for the user.
    ///   - completion: A closure to be called when the update process is completed. It takes an optional `Error` parameter, which will be `nil` if the update was successful, or an `Error` object if an error occurred during the update process.
    static func setProfessionDetails(withCredentials credentials: AuthCredentials, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        guard let uid = credentials.uid, let kind = credentials.kind, let discipline = credentials.discipline, let speciality = credentials.speciality else {
            completion(.unknown)
            return
        }
        
        let user: [String: Any] = ["phase": credentials.phase.rawValue,
                                   "kind": kind.rawValue,
                                   "discipline": discipline.rawValue,
                                   "speciality": speciality.rawValue]
        
        COLLECTION_USERS.document(uid).updateData(user) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
            } else {
                completion(nil)
                setUserHistory(for: .phase, with: credentials.phase.rawValue)
            }
        }

    }
    
    /// Updates the registration name details of a user in Firebase.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier (UID) of the user.
    ///   - credentials: The updated authentication credentials for the user.
    ///   - completion: A closure to be called when the update process is completed. It takes an optional `Error` parameter, which will be `nil` if the update was successful, or an `Error` object if an error occurred during the update process.
    static func setProfileDetails(withCredentials credentials: AuthCredentials, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        guard let uid = credentials.uid, let firstName = credentials.firstName?.capitalized, let lastName = credentials.lastName?.capitalized else {
            completion(.unknown)
            return
        }
        
        var user: [String: Any] = ["firstName": firstName,
                                   "lastName": lastName,
                                   "phase": credentials.phase.rawValue]
        
        if let imageUrl = credentials.imageUrl {
            user["imageUrl"] = imageUrl
        }
        
        COLLECTION_USERS.document(uid).updateData(user) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
            } else {
                completion(nil)
                setUserHistory(for: .phase, with: credentials.phase.rawValue)
            }
        }
    }
    
    /// Skip documentation details for a user.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user.
    ///   - completion: A closure to be called when the operation completes. It will pass a `FirestoreError` indicating the result of the operation.
    static func skipDocumentationDetails(withUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let user: [String: Any] = ["phase": UserPhase.pending.rawValue]
        
        COLLECTION_USERS.document(uid).updateData(user) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
            } else {
                completion(nil)
                setUserHistory(for: .phase, with: UserPhase.pending.rawValue)
            }
        }
    }
    
    /// Add documentation details for a user.
    ///
    /// - Parameters:
    ///   - uid: The UID of the user.
    ///   - completion: A closure to be called when the operation completes. It will pass a `FirestoreError` indicating the result of the operation.
    static func addDocumentationDetals(withUid uid: String, completion: @escaping(FirestoreError?) -> Void) {
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }

        let user: [String: Any] = ["phase": UserPhase.review.rawValue]
        
        COLLECTION_USERS.document(uid).updateData(user) { error in
            if let error {
                let nsError = error as NSError
                let errCode = FirestoreErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .notFound:
                    completion(.notFound)
                default:
                    completion(.unknown)
                }
            } else {
                completion(nil)
                setUserHistory(for: .phase, with: UserPhase.review.rawValue)
            }
        }
    }

    /// Fetch the authentication providers associated with an email address.
    ///
    /// - Parameters:
    ///   - email: The email address to check for authentication providers.
    ///   - completion: A closure to be called when the operation completes. It will pass a `Result` containing a `Provider` enum value or a `PasswordResetError`.
    static func fetchProviders(withEmail email: String, completion: @escaping(Result<Provider, PasswordResetError>) -> Void) {
    
        Auth.auth().fetchSignInMethods(forEmail: email) { providers, error in
            if let error {
                let nsError = error as NSError
                let errCode = AuthErrorCode(_nsError: nsError)
                switch errCode.code {
                case .invalidSender, .invalidCredential, .invalidEmail:
                    completion(.failure(.invalidEmail))
                case .networkError:
                    completion(.failure(.network))
                case .userNotFound:
                    completion(.failure(.userNotFound))
                default:
                    completion(.failure(.unknown))
                }
                
                return
            }
            
            if let providers = providers {
                if providers.contains(Provider.google.id) {
                    completion(.success(.google))
                    return
                } else if providers.contains(Provider.apple.id) {
                    completion(.success(.apple))
                    return
                } else if providers.contains(Provider.password.id) {
                    completion(.success(.password))
                    return
                } else {
                    completion(.success(.undefined))
                    return
                }
            } else {
                completion(.failure(.userNotFound))
            }
        }
    }
    
    /// Check if a user with the given email exists.
    ///
    /// - Parameters:
    ///   - email: The email address to check.
    ///   - completion: A closure to be called when the operation completes. It will pass a `SignUpError` or `nil`.
    static func userExists(withEmail email: String, completion: @escaping(SignUpError?) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { providers, error in
            if let error {
                let nsError = error as NSError
                let errCode = AuthErrorCode(_nsError: nsError)
                switch errCode.code {
                case .invalidSender, .invalidCredential, .invalidEmail:
                    completion(.invalidEmail)
                case .networkError:
                    completion(.network)
                case .userNotFound:
                    completion(nil)
                default:
                    completion(.unknown)
                }
            } else {
                if let _ = providers {
                    completion(.userFound)
                } else {
                    completion(nil)
                }
            }
        }
    }
        
    /// Sends a password reset email to the provided email address.
    ///
    /// - Parameters:
    ///   - email: The email address associated with the user's account.
    ///   - completion: A closure to be called when the password reset email is sent. It takes an optional `Error` parameter, which will be `nil` if the email was sent successfully, or an `Error` object if an error occurred during the process.
    static func resetPassword(withEmail email: String, completion: @escaping(PasswordResetError?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                let nsError = error as NSError
                let errCode = AuthErrorCode(_nsError: nsError)
                switch errCode.code {
                case .invalidSender, .invalidCredential, .invalidEmail:
                    completion(.invalidEmail)
                case .networkError:
                    completion(.network)
                case .userNotFound:
                    completion(.userNotFound)
                default:
                    completion(.unknown)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    /// Determine the provider kind of the current user.
    ///
    /// - Parameter completion: A closure to be called when the operation completes. It will pass a `Provider`.
    static func providerKind(completion: @escaping(Provider) -> Void) {
        if let currentUser = Auth.auth().currentUser {
            for userInfo in currentUser.providerData {
                let providerID = userInfo.providerID
                if providerID == "password" {
                    completion(.password)
                } else if providerID == "google.com" {
                    completion(.google)
                } else if providerID == "apple.com" {
                    completion(.apple)
                } else {
                    completion(.undefined)
                }
            }
        } else {
            completion(.undefined)
        }
    }
    
    /// Reauthenticate the current user with the provided password.
    ///
    /// - Parameters:
    ///   - password: The password for reauthentication.
    ///   - completion: A closure to be called when the operation completes. It will pass a `PasswordResetError` if there's an error, or `nil` if successful.
    static func reauthenticate(with password: String, completion: @escaping(PasswordResetError?) -> Void) {
        guard let currentUser = Auth.auth().currentUser, let email = currentUser.email else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        currentUser.reauthenticate(with: credential) { result, error in
            if let error = error {
                let nsError = error as NSError
                let errCode = AuthErrorCode(_nsError: nsError)
                switch errCode.code {
                case .networkError:
                    completion(.network)
                default:
                    completion(.unknown)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    /// Deactivate the current user's account.
    ///
    /// - Parameter completion: A closure to be called when the operation completes. It will pass an `Error` if there's an error, or `nil` if successful.
    static func deactivate(completion: @escaping(Error?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }

        let timestamp = Timestamp()
        let data: [String: Any] = ["phase": UserPhase.deactivate.rawValue,
                                   "dDate": timestamp]
        
        let historyData: [String: Any] = ["value": UserPhase.deactivate.rawValue,
                                   "timestamp": timestamp]
        
        COLLECTION_HISTORY.document(uid).collection(UserHistory.phase.path).addDocument(data: historyData) { error in
            if let _ = error {
                return
            } else {
                COLLECTION_USERS.document(uid).updateData(data, completion: completion)
            }
        }
    }
    
    /// Activate a user with a specified `dDate`.
    ///
    /// - Parameters:
    ///   - dDate: The deactivation date.
    ///   - completion: A closure to be called when the operation completes. It will pass a `FirestoreError` if there's an error, or `nil` if successful.
    static func activate(dDate: Timestamp, completion: @escaping(FirestoreError?) -> Void) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            return
        }
        
        guard NetworkMonitor.shared.isConnected else {
            completion(.network)
            return
        }
        
        let query = COLLECTION_HISTORY.document(uid).collection(UserHistory.phase.path).order(by: "timestamp", descending: true).whereField("timestamp", isLessThan: dDate).limit(to: 1)
        
        query.getDocuments { snapshot, error in
            if let error {
                let nsError = error as NSError
                let _ = FirestoreErrorCode(_nsError: nsError)
                completion(.unknown)
            } else {
                guard let document = snapshot?.documents.first else {
                    completion(.notFound)
                    return
                }

                let data = document.data()
                if let previousPhase = data["value"] as? Int {
                    let data: [String: Any] = ["value": previousPhase,
                                               "timestamp": Timestamp()]

                    COLLECTION_HISTORY.document(uid).collection(UserHistory.phase.path).addDocument(data: data) { error in
                        if let error {
                            let nsError = error as NSError
                            let _ = FirestoreErrorCode(_nsError: nsError)
                            completion(.unknown)
                        } else {
                            let phaseData: [String: Any] = ["dDate": FieldValue.delete(),
                                                            "phase": previousPhase]
                            
                            COLLECTION_USERS.document(uid).updateData(phaseData) { error in
                                if let error {
                                    let nsError = error as NSError
                                    let _ = FirestoreErrorCode(_nsError: nsError)
                                    completion(.unknown)
                                } else {
                                    completion(nil)
                                }
                            }
                        }
                    }
                } else {
                    completion(.unknown)
                }
            }
        }
    }
    
    /// Change the password for the current user.
    ///
    /// - Parameters:
    ///   - password: The new password to set.
    ///   - completion: A closure to be called when the operation completes. It will pass a `PasswordResetError` if there's an error, or `nil` if successful.
    static func changePassword(_ password: String, completion: @escaping(PasswordResetError?) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: password) { error in
            if let _ = error {
                completion(.unknown)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Retrieve the current user's email.
    static func userEmail(completion: @escaping(String?) -> Void) {
        completion(Auth.auth().currentUser?.email)
    }
    
    /// Send an email verification to the current user's new email address before updating it.
    ///
    /// - Parameters:
    ///   - email: The new email address to set.
    ///   - completion: A closure to be called when the operation completes. It will pass a `SignUpError` if there's an error, or `nil` if successful.
    static func changeEmail(to email: String, completion: @escaping(SignUpError?) -> Void) {
        Auth.auth().currentUser?.sendEmailVerification(beforeUpdatingEmail: email) { error in
            if let error = error {
                let nsError = error as NSError
                let errCode = AuthErrorCode(_nsError: nsError)
                
                switch errCode.code {
                case .networkError:
                    completion(.network)
                default:
                    completion(.unknown)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    /// Logs out the currently authenticated user from Firebase.
    static func logout() {
        do {
             if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let uid = UserDefaults.standard.value(forKey: "uid") as? String {
                 appDelegate.removeFCMToken(for: uid)
             }
             
            try Auth.auth().signOut()
           
            UserDefaults.resetDefaults()
            DataService.shared.reset()
        } catch {
            return
        }
    }
    
    /// Logs out the user from the Google sign-in provider.
    static func googleLogout() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, let uid = UserDefaults.standard.value(forKey: "uid") as? String {
            appDelegate.removeFCMToken(for: uid)
        }

        GIDSignIn.sharedInstance.signOut()
        
        UserDefaults.resetDefaults()
        DataService.shared.reset()
    }
    
    /// Set user history information based on the given type and value.
    ///
    /// - Parameters:
    ///   - type: The type of user history.
    ///   - value: The value associated with the user history.
    static func setUserHistory(for type: UserHistory, with value: Any) {
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else { return }
        let path = COLLECTION_HISTORY.document(uid).collection(type.path).document()
        
        switch type {
        case .logIn:
            break
        case .phase:
            let phaseData: [String: Any] = ["timestamp": Timestamp(),
                                            "value": value]
            path.setData(phaseData)
        case .password:
            break
        }
    }
}
