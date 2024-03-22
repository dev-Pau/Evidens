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
    var email: String?
    let uid: String?
    var username: String?
    var profileUrl: String?
    var bannerUrl: String?
    var phase: UserPhase
    var kind: UserKind
    var discipline: Discipline?
    var speciality: Speciality?
    var dDate: Timestamp?
    
    var isFollowed = false
    //var connectPhase: ConnectPhase = .none
    var connection: UserConnection?
    
    var stats: UserStats
    private(set) var blockPhase: BlockPhase?
    
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
        self.username = dictionary["username"] as? String ?? ""
        self.profileUrl = dictionary["imageUrl"] as? String ?? ""
        self.bannerUrl = dictionary["bannerUrl"] as? String ?? ""
        self.kind = UserKind(rawValue: dictionary["kind"] as? Int ?? 0) ?? .professional
        self.phase = UserPhase(rawValue: dictionary["phase"] as? Int ?? 0) ?? .pending
        
        self.discipline = Discipline(rawValue: dictionary["discipline"] as? Int ?? 0) ?? .medicine
        self.speciality = Speciality(rawValue: dictionary["speciality"] as? Int ?? 0) ?? .generalMedicine
        
        if let dDate = dictionary["dDate"] as? Timestamp {
            self.dDate = dDate
        }
        
        self.stats = UserStats()
    }
    
    var isCurrentUser: Bool {
        guard let uid = UserDefaults.getUid() else {
            return false
        }
        return uid == self.uid
    }
    
    var hasProfileImage: Bool {
       guard let profileUrl else {
            return false
        }
        
        return !profileUrl.isEmpty
    }
    
    var hasBannerImage: Bool {
       guard let bannerUrl else {
            return false
        }
        
        return !bannerUrl.isEmpty
    }
}

extension User {
    
    func details() -> String {
        if kind == .evidens {
            return AppStrings.Global.official
        } else {
            guard let speciality = speciality else {
                return ""
            }
            return speciality.name
        }
    }
    
    func name() -> String {
        guard let firstName = firstName, let lastName = lastName else {
            return ""
        }
        
        if lastName.isEmpty {
            return firstName + " "
        } else {
            return firstName + " " + lastName + " "
        }
    }
    
    func getUsername() -> String {
        guard let username else { return "" }
        return AppStrings.Characters.atSign.appending(username)
    }
}

//MARK: - Edit Operations

extension User {
    
    mutating func set(isFollowed: Bool) {
        self.isFollowed = isFollowed
    }
    
    mutating func set(connection: UserConnection) {
        self.connection = connection
    }
    
    mutating func editConnectionPhase(phase: ConnectPhase) {
        self.connection?.phase = phase
        self.connection?.timestamp = Timestamp(date: .now)
    }
    
    mutating func set(email: String) {
        self.email = email
    }
    
    mutating func set(username: String) {
        self.username = username
    }
    
    mutating func set(blockPhase: BlockPhase?) {
        self.blockPhase = blockPhase
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}
