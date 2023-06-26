//
//  User.swift
//  Evidens
//
//  Created by Pau Fernández Solà on 10/10/21.
//

import UIKit
import Firebase
import FirebaseAuth

/// The model for a User
struct User {
    
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
    var dDate: Timestamp?
    var isFollowed = false
    var stats: UserStats!
    var interests: [String]?
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == uid }
    
    /// Initializes a new instance of a User using a dictionary.
    ///
    /// - Parameters:
    ///   - dictionary: A dictionary containing the user data.
    ///     - Key: The key representing the specific data field.
    ///     - Value: The value associated with the key.
    init(dictionary: [String: Any]) {
        self.firstName = dictionary["firstName"] as? String ?? ""
        self.lastName = dictionary["lastName"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.bannerImageUrl = dictionary["bannerImageUrl"] as? String ?? ""
        self.category = UserCategory(rawValue: dictionary["category"] as? Int ?? 00) ?? .professional
        self.phase = UserRegistrationPhase(rawValue: dictionary["phase"] as? Int ?? 00) ?? .categoryPhase
        self.dDate = dictionary["dDate"] as? Timestamp ?? Timestamp()
        self.profession = dictionary["profession"] as? String ?? ""
        self.speciality = dictionary["speciality"] as? String ?? ""
        self.interests = dictionary["interests"] as? [String] ?? []
    
        self.stats = UserStats(followers: 0, following: 0, posts: 0, cases: 0)
    }
}

extension User {
    
    /// An enum mapping the registration phase.
    enum UserRegistrationPhase: Int {
        case categoryPhase
        case userDetailsPhase
        case verificationPhase
        case awaitingVerification
        case verified
        case deactivate
        case ban
        
        var content: String {
            switch self {
            case .categoryPhase, .userDetailsPhase, .deactivate, .ban: return String()
            case .verificationPhase: return "Verify Account"
            case .awaitingVerification: return "Awaiting Verification"
            case .verified: return "Account Verified"
            }
        }
    }
    
    /// An enum mapping the category of a user.
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
    
    
    func getUserAttributedInfo() -> NSAttributedString {
        let attributedText = NSMutableAttributedString(string: "\(profession!), ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)])
        if category == .professional {
            attributedText.append(NSAttributedString(string: "\(speciality!)", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]))
        } else {
            attributedText.append(NSAttributedString(string: "\(speciality!) • ", attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular)]))
            attributedText.append(NSAttributedString(string: category.userCategoryString, attributes: [.font: UIFont.systemFont(ofSize: 12, weight: .regular), .foregroundColor: primaryColor]))
            
        }
        return attributedText
    }
    
    func userLabelText() -> NSAttributedString {
        if category == .professional {
            let attributedString = NSMutableAttributedString(string: firstName! + " " + lastName!, attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            return attributedString
        } else {
            let attributedString = NSMutableAttributedString(string: firstName! + " " + lastName! + " • ", attributes: [.font: UIFont.boldSystemFont(ofSize: 14)])
            attributedString.append(NSAttributedString(string: "Student", attributes: [.font: UIFont.boldSystemFont(ofSize: 14), .foregroundColor: primaryColor]))
            return attributedString
        }
    }
}

/// The model for the UserStats.
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
