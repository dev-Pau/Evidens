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
}

struct AuthService {
    
    static func logUserIn(withEmail email: String, password: String, completion: AuthDataResultCallback?) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        
            Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { (result, error) in
                
                if let error = error { return }
                
                //Unique identifier of user
                guard let uid = result?.user.uid else { return }
                
                let data: [String: Any] = ["firstName": credentials.firstName, "lastName": credentials.lastName, "email": credentials.email, "uid": uid, "profileImageUrl": ""]
                
                
                COLLECTION_USERS.document(uid).setData(data, completion: completion)
                
                //Add user info to Realtime Database for chat purposes
                DatabaseManager.shared.insertUser(with: ChatUser(firstName: credentials.firstName, lastName: credentials.lastName, emailAddress: credentials.email, uid: uid))
        }
    }
    
    static func resetPassword(withEmail email: String, completion: SendPasswordResetCallback?) {
        Auth.auth().sendPasswordReset(withEmail: email, completion: completion)
    }
    
}

