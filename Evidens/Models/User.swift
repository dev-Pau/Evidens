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
    
    enum UserRegistrationPhase: Int {
        case categoryPhase
        case userDetailsPhase
        case verificationPhase
        case verified
    }
    
    enum UserCategory: Int {
        case none
        case professional
        case professor
        case student
        case researcher
        
        var userCategoryString: String {
            switch self {
            case .none:
                return "none"
            case .professional:
                return "Healthcare professional"
            case .professor:
                return "Professor"
            case .student:
                return "Student"
            case .researcher:
                return "Research scientist"
            }
        }
        
        
        /*
        var notificationMessage: String {
            switch self {
            case .likePost: return " liked your post"
            case .likeReply: return " liked your reply"
            case .follow: return " followed you"
            case .comment: return " commented on your post"
            }
        }
         */
    }
    
    
    
    let firstName: String?
    let lastName: String?
    let email: String?
    let uid: String?
    var profileImageUrl: String?
    var phase: UserRegistrationPhase
    var category: UserCategory
    var profession: String?
    var speciality: String?
    
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
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.category = UserCategory(rawValue: dictionary["category"] as? Int ?? 00) ?? .professional
        self.phase = UserRegistrationPhase(rawValue: dictionary["phase"] as? Int ?? 00) ?? .categoryPhase
        self.profession = dictionary["profession"] as? String ?? ""
        self.speciality = dictionary["speciality"] as? String ?? ""
    
        self.stats = UserStats(connections: 0, followers: 0, following: 0, posts: 0, cases: 0)
    }
}

struct UserStats {
    let connections: Int
    let followers: Int
    let following: Int
    let posts: Int
    let cases: Int
}
