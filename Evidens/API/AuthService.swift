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
}

struct AuthService {
    static func registerUser(withCredential credentials: AuthCredentials, completion: @escaping(Error?) -> Void) {
        Auth.auth().createUser(withEmail: credentials.email, password: credentials.password) { result, error in
            
            if let error = error {
                print("DEBUG: Failed to register user \(error.localizedDescription)")
                return
            }
            
            //Unique identifier of user
            guard let uid = result?.user.uid else { return }
            
            let data: [String: Any] = ["firstName": credentials.firstName, "lastName": credentials.lastName, "email": credentials.email, "uid": uid]
            
            Firestore.firestore().collection("users").document(uid).setData(data, completion: completion)
        }
    }
}
