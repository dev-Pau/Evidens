//
//  DatabaseManager.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 9/12/21.
//

import UIKit
import FirebaseDatabase

final class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
}

//MARK: - Account Management

extension DatabaseManager {
    
    /// Inserts new user to database
    public func insertUser(with user: ChatUser) {
        database.child(user.uid).setValue(["firstName": user.firstName,
                                           "lastName": user.lastName,
                                           "emailAddress": user.emailAddress])
    }
}

struct ChatUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    let uid: String
    //let profilePictureUrl: URL
}
