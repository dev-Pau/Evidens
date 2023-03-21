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
        case awaitingVerification
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
                return "Professional"
            case .professor:
                return "Professor"
            case .student:
                return "Student"
            case .researcher:
                return "Research scientist"
            }
        }
    }
    
    var firstName: String?
    var lastName: String?
    let email: String?
    let uid: String?
    var profileImageUrl: String?
    var bannerImageUrl: String?
    var phase: UserRegistrationPhase
    var category: UserCategory
    var profession: String?
    var speciality: String?
    var isFollowed = false
    var stats: UserStats!
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    

    init(dictionary: [String: Any]) {
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.bannerImageUrl = dictionary["bannerImageUrl"] as? String ?? ""
        self.category = UserCategory(rawValue: dictionary["category"] as? Int ?? 00) ?? .professional
        self.phase = UserRegistrationPhase(rawValue: dictionary["phase"] as? Int ?? 00) ?? .categoryPhase
        self.profession = dictionary["profession"] as? String ?? ""
        self.speciality = dictionary["speciality"] as? String ?? ""
    
        self.stats = UserStats(followers: 0, following: 0, posts: 0, cases: 0)
    }
}

extension User {
    func getUserAttributedInfo() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(profession!), ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)])
        if category == .professional {
            attributedText.append(NSAttributedString(string: "\(speciality!)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]))
        } else {
            attributedText.append(NSAttributedString(string: "\(speciality!) · ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium)]))
            attributedText.append(NSAttributedString(string: category.userCategoryString, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .medium), .foregroundColor: primaryColor]))
            
        }
        return attributedText
    }
    
    func userLabelText() -> NSAttributedString {
        if category == .professional {
            let attributedString = NSMutableAttributedString(string: firstName! + " " + lastName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            return attributedString
        } else {
            let attributedString = NSMutableAttributedString(string: firstName! + " " + lastName! + " · ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: "Student", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: primaryColor]))
            return attributedString
        }
    }
}

struct UserStats {
    var followers: Int
    var following: Int
    var posts: Int
    var cases: Int
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    
}
