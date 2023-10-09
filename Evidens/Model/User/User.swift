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
    var hobbies: [Discipline]?
    
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
        guard let uid = UserDefaults.standard.value(forKey: "uid") as? String else {
            return false
        }
        return uid == self.uid
    }
}

extension User {
    
    func details() -> String {
        if kind == .evidens {
            return AppStrings.Global.official
        } else {
            guard let profession = discipline, let speciality = speciality else {
                return ""
            }
            return profession.name + AppStrings.Characters.dot + speciality.name
        }
    }
    
    func name() -> String {
        guard let firstName = firstName, let lastName = lastName else {
            return ""
        }
        return firstName + " " + lastName
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
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.uid == rhs.uid
    }
}
