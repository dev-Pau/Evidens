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

/// The model for AuthCredentials
struct AuthCredentials {
    var firstName: String
    var lastName: String
    let email: String
    let password: String
    let profileImageUrl: String
    var phase: User.UserRegistrationPhase
    var category: User.UserCategory
    var profession: String
    var speciality: String
    var interests: [String]
}

/// A authentication service used to interface with FirebaseAuth.
struct AuthService {
    
    /// Logs in a user with the provided email and password credentials in Firebase.
    ///
    /// - Parameters:
    ///   - email: The user's email address.
    ///   - password: The user's password.
    ///   - completion: A closure to be called when the login process is completed. It takes two optional parameters: an `AuthDataResult` object containing information about the authenticated user, or `nil` if the login was unsuccessful, and an `Error` object if an error occurred during the login process.
    static func logUserIn(withEmail email: String, password: String, completion: @escaping(AuthDataResult?, Error?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let error = error {
                completion(nil, error)
            } else {
                completion(authResult, nil)
            }
        }
    }
    
    /// Registers a new user with the provided credentials in Firebase.
    ///
    /// - Parameters:
    ///   - credentials: The authentication credentials for the user.
    ///   - completion: A closure to be called when the registration process is completed. It takes an optional `Error` parameter, which will be `nil` if the registration was successful, or an `Error` object if an error occurred during the registration process.
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
            if let error = error {
                completion(error)
            } else {
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = ["firstName": credentials.firstName.capitalized,
                                           "lastName": credentials.lastName.capitalized,
                                           "email": credentials.email,
                                           "uid": uid,
                                           "phase": credentials.phase.rawValue,
                                           "category": credentials.category.rawValue,
                                           "profession": credentials.profession,
                                           "speciality": credentials.speciality]
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
            }
        }
    }
    
    /// Registers a new user with the provided Google credentials and user UID in Firebase.
    ///
    /// - Parameters:
    ///   - credentials: The authentication credentials for the user obtained from Google Sign-In.
    ///   - uid: The unique identifier (UID) of the user.
    ///   - completion: A closure to be called when the registration process is completed. It takes an optional `Error` parameter, which will be `nil` if the registration was successful, or an `Error` object if an error occurred during the registration process.
    static func registerGoogleUser(withCredential credentials: AuthCredentials, withUid uid: String, completion: @escaping(Error?) -> Void) {
        let data: [String: Any] = ["firstName": credentials.firstName.capitalized,
                                   "lastName": credentials.lastName.capitalized,
                                   "email": credentials.email,
                                   "uid": uid,
                                   "phase": credentials.phase.rawValue,
                                   "category": credentials.category.rawValue,
                                   "profession": credentials.profession,
                                   "speciality": credentials.speciality]
        
        COLLECTION_USERS.document(uid).setData(data, completion: completion)
        
    }
    
    /// Registers a new user with the provided Apple credentials and user UID in Firebase.
    ///
    /// - Parameters:
    ///   - credentials: The authentication credentials for the user obtained from Apple Sign-In.
    ///   - uid: The unique identifier (UID) of the user.
    ///   - completion: A closure to be called when the registration process is completed. It takes an optional `Error` parameter, which will be `nil` if the registration was successful, or an `Error` object if an error occurred during the registration process.
    static func registerAppleUser(withCredential credentials: AuthCredentials, withUid uid: String, completion: @escaping(Error?) -> Void) {
        
        let data: [String: Any] = ["firstName": credentials.firstName.capitalized,
                                   "lastName": credentials.lastName.capitalized,
                                   "email": credentials.email,
                                   "uid": uid,
                                   "phase": credentials.phase.rawValue,
                                   "category": credentials.category.rawValue,
                                   "profession": credentials.profession,
                                   "speciality": credentials.speciality]
        
        COLLECTION_USERS.document(uid).setData(data, completion: completion)
    }
    
    /// Updates the registration category details of a user in Firebase.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier (UID) of the user.
    ///   - credentials: The updated authentication credentials for the user.
    ///   - completion: A closure to be called when the update process is completed. It takes an optional `Error` parameter, which will be `nil` if the update was successful, or an `Error` object if an error occurred during the update process.
    static func updateUserRegistrationCategoryDetails(withUid uid: String, withCredentials credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        let data: [String: Any] = ["phase": credentials.phase.rawValue,
                                   "category": credentials.category.rawValue,
                                   "profession": credentials.profession,
                                   "speciality": credentials.speciality]
        
        COLLECTION_USERS.document(uid).updateData(data, completion: completion)
    }
    
    /// Updates the registration name details of a user in Firebase.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier (UID) of the user.
    ///   - credentials: The updated authentication credentials for the user.
    ///   - completion: A closure to be called when the update process is completed. It takes an optional `Error` parameter, which will be `nil` if the update was successful, or an `Error` object if an error occurred during the update process.
    static func updateUserRegistrationNameDetails(withUid uid: String, withCredentials credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        var data = [String: Any]()
        if credentials.interests.isEmpty {
            data = ["phase": credentials.phase.rawValue,
                                       "firstName": credentials.firstName.capitalized,
                                       "lastName": credentials.lastName.capitalized]
        } else {
            data = ["phase": credentials.phase.rawValue,
                                       "firstName": credentials.firstName.capitalized,
                                       "lastName": credentials.lastName.capitalized,
                                       "interests": credentials.interests]
        }
       
        COLLECTION_USERS.document(uid).updateData(data, completion: completion)
    }
    
    /// Updates the registration documentation details of a user in Firebase.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier (UID) of the user.
    ///   - membershipCode: The membership code associated with the user's documentation.
    ///   - completion: A closure to be called when the update process is completed. It takes an optional `Error` parameter, which will be `nil` if the update was successful, or an `Error` object if an error occurred during the update process.
    static func updateUserRegistrationDocumentationDetails(withUid uid: String, withMembershipCode membershipCode: String, completion: @escaping(Error?) -> Void) {
        let data: [String: Any] = ["phase": User.UserRegistrationPhase.awaitingVerification.rawValue,
                                   "membershipCode": membershipCode]
        COLLECTION_USERS.document(uid).updateData(data, completion: completion)
    }
    
    /// Updates the registration documentation details of a user in Firebase.
    ///
    /// - Parameters:
    ///   - uid: The unique identifier (UID) of the user.
    ///   - completion: A closure to be called when the update process is completed. It takes an optional `Error` parameter, which will be `nil` if the update was successful, or an `Error` object if an error occurred during the update process.
    static func updateUserRegistrationDocumentationDetails(withUid uid: String, completion: @escaping(Error?) -> Void) {
        let data: [String: Any] = ["phase": User.UserRegistrationPhase.awaitingVerification.rawValue]
        COLLECTION_USERS.document(uid).updateData(data, completion: completion)
    }
    
    /// Sends a password reset email to the provided email address.
    ///
    /// - Parameters:
    ///   - email: The email address associated with the user's account.
    ///   - completion: A closure to be called when the password reset email is sent. It takes an optional `Error` parameter, which will be `nil` if the email was sent successfully, or an `Error` object if an error occurred during the process.
    static func resetPassword(withEmail email: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
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
        }
        completion(.undefined)
    }
    
    static func reauthenticate(with password: String, completion: @escaping(Error?) -> Void) {
        guard let currentUser = Auth.auth().currentUser, let email = currentUser.email else { return }
        
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        currentUser.reauthenticate(with: credential) { result, error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    static func changePassword(_ password: String, completion: @escaping(Error?) -> Void) {
        Auth.auth().currentUser?.updatePassword(to: password) { error in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Logs out the currently authenticated user from Firebase.
    static func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Logs out the user from the Google sign-in provider.
    static func googleLogout() {
        GIDSignIn.sharedInstance.signOut()
    }
    
}

