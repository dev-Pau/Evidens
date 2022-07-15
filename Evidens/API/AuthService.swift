//
//  AuthService.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 24/10/21.
//

import UIKit
import Firebase
import FirebaseFirestore

struct AuthCredentials {
    let firstName: String
    let lastName: String
    let email: String
    let password: String
    let profileImageUrl: String
    var phase: User.UserRegistrationPhase
    var category: User.UserCategory
    var profession: String
    var speciality: String
}

struct AuthService {
    
    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                
                if let _ = error { return }
                
                //Unique identifier of user
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = ["firstName": credentials.firstName,
                                           "lastName": credentials.lastName,
                                           "email": credentials.email,
                                           "uid": uid,
                                           "profileImageUrl": "",
                                           "phase": credentials.phase.rawValue,
                                           "category": credentials.category.rawValue,
                                           "profession": credentials.profession,
                                           "speciality": credentials.speciality]
                

                COLLECTION_USERS.document(uid).setData(data, completion: completion)
                
                DatabaseManager.shared.insertUser(with: ChatUser(firstName: credentials.firstName, lastName: credentials.lastName, emailAddress: credentials.email, uid: uid))    
        }
    }
    
    static func updateUserRegistrationData(withUid uid: String, withCredentials credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        
        let data: [String: Any] = ["phase": credentials.phase.rawValue,
                                    "category": credentials.category.rawValue,
                                   "profession": credentials.profession,
                                   "speciality": credentials.speciality]
        
        COLLECTION_USERS.document(uid).updateData(data, completion: completion)
        }
    
    
    static func resetPassword(withEmail email: String, completion: SendPasswordResetCallback?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
    static func logout() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("DEBUG: Failed to logout")
        }
    }
    
}

