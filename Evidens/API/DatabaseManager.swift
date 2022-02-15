//
//  DatabaseManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/21.
//

import UIKit
import FirebaseDatabase
import RealmSwift

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
}

//MARK: - Account Management

extension DatabaseManager {
    
    /// Inserts new user to database
    public func insertUser(with user: ChatUser) {
        //Create user entry based on UID
        database.child(user.uid).setValue(["firstName": user.firstName,
                                           "lastName": user.lastName,
                                           "emailAddress": user.emailAddress])
        
        self.database.child("users").observeSingleEvent(of: .value) { snapshot in
            if var userCollection = snapshot.value as? [[String: String]] {
                //append to user dictionary
                let newUser = ["name": user.firstName + " " + user.lastName,
                               "emailAddress": user.emailAddress,
                               "uid": user.uid
                              ]
                userCollection.append(newUser)
                
                self.database.child("users").setValue(userCollection) { error, _ in
                    if let error = error { return }
                }
                
                //completion(true)
                
            } else {
                //create the array - only the first user that gets created
                let newCollection: [[String: String]] = [["name": user.firstName + " " + user.lastName,
                                                          "emailAddress": user.emailAddress,
                                                          "uid": user.uid
                                                         ]]
                self.database.child("users").setValue(newCollection) { error, _ in
                    if let error = error { return }
                }
                
                //completion(true)
            }
        }
    }
    
    public func getAllUsers(completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
    
}


struct ChatUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let uid: String
    //let profilePictureUrl: URL
}
