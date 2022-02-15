//
//  User.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/10/21.
//

import UIKit
import Firebase
import FirebaseAuth

struct User {
    let firstName: String?
    let lastName: String?
    let email: String?
    let uid: String?
    let isVerified: Bool?
    var profileImageUrl: String?
    var category: String?
    
    //Track if a user is followed
    var isFollowed = false
    
    var stats: UserStats!
    
    //Track if the user is current user
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    init(dictionary: [String: Any]) {
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.isVerified = dictionary["isVerified"] as? Bool ?? false
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.category = dictionary["category"] as? String ?? ""
        
        self.stats = UserStats(followers: 0, following: 0, posts: 0)
    }
}

struct UserStats {
    let followers: Int
    let following: Int
    let posts: Int
}
